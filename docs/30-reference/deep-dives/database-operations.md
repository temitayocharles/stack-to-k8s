---
title: "Production Database Operations Guide"
level: "intermediate-to-advanced"
type: "deep-dive"
prerequisites: ["Lab 3: Stateful Workloads", "Basic SQL knowledge"]
topics: ["Backup & Restore", "Point-in-Time Recovery", "Database Migrations", "Disaster Recovery"]
estimated_time: "45-60 minutes"
updated: "2025-10-21"
nav_prev: "./resource-requirements.md"
nav_next: "./node-operations.md"
---

# 🗄️ Production Database Operations: Backup, Recovery, and Beyond

Production databases in Kubernetes require careful handling of backups, recovery, and disaster scenarios. This guide covers the critical operations every platform engineer must master.

---

## 📋 Quick Navigation

- [Backup Strategies](#backup-strategies-your-data-insurance)
- [Point-in-Time Recovery (PITR)](#point-in-time-recovery-pitr)
- [Restore Operations](#restore-operations-bringing-data-back)
- [Database Migrations](#database-migrations-moving-data-safely)
- [Disaster Recovery Scenarios](#disaster-recovery-scenarios)
- [Testing Your Backups](#testing-your-backups)
- [Monitoring & Alerting](#monitoring--alerting)

---

## 🔄 Backup Strategies: Your Data Insurance

### Strategy 1: Persistent Volume Snapshots

**Use when**: Your storage provider supports snapshots (AWS EBS, GCP Persistent Disk, Azure Disk)

**Pros**:
- ✅ Fast and incremental
- ✅ Low storage overhead
- ✅ Works with any database

**Cons**:
- ❌ Requires storage provider support
- ❌ Database-agnostic (can miss application consistency)

**Implementation**:

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: postgres-backup-$(date +%Y%m%d)
spec:
  volumeSnapshotClassName: csi-snapshotter
  source:
    persistentVolumeClaimName: postgres-data-pvc
```

**When to use**: Hourly/daily backups of stateful services

---

### Strategy 2: Database-Level Backups (PostgreSQL Example)

**Use when**: You need point-in-time recovery and application consistency

**Pros**:
- ✅ Application-aware consistency
- ✅ Works across storage providers
- ✅ Portable format (can restore anywhere)

**Cons**:
- ❌ More resource-intensive
- ❌ Requires database tools

**Full Backup Job**:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: databases
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: postgres-backup
          containers:
          - name: backup
            image: postgres:15
            env:
            - name: PGHOST
              value: postgres-service
            - name: PGUSER
              value: postgres
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-credentials
                  key: password
            command:
            - /bin/bash
            - -c
            - |
              BACKUP_FILE="/backups/postgres-full-$(date +\%Y\%m\%d-\%H\%M\%S).sql.gz"
              pg_dump -h $PGHOST -U $PGUSER --all --compress=9 > $BACKUP_FILE
              echo "Backup completed: $BACKUP_FILE"
              
              # Upload to cloud storage (example: S3)
              aws s3 cp $BACKUP_FILE s3://my-backups/postgres/
            volumeMounts:
            - name: backups
              mountPath: /backups
          volumes:
          - name: backups
            emptyDir: {}
          restartPolicy: OnFailure
```

**Incremental Backup with WAL Archiving**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-wal-config
data:
  postgresql.conf: |
    wal_level = replica
    archive_mode = on
    archive_command = 'aws s3 cp "%p" "s3://my-backups/wal/%f"'
    archive_timeout = 300
```

**Key Settings**:
- `wal_level = replica` — Enables WAL archiving for PITR
- `archive_command` — Send WAL files to S3 continuously
- `archive_timeout` — Archive WAL even if DB is idle

---

### Strategy 3: Continuous Replication

**Use when**: You need high availability and fast recovery

**Pros**:
- ✅ Near-zero RTO (recovery time objective)
- ✅ Active-standby architecture
- ✅ Can promote standby instantly

**Cons**:
- ❌ Requires 2+ database nodes
- ❌ Network overhead

**Primary-Standby Setup**:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-ha
spec:
  serviceName: postgres
  replicas: 2
  selector:
    matchLabels:
      app: postgres
      role: replica
  template:
    metadata:
      labels:
        app: postgres
        role: replica
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: PGUSER
          value: postgres
        ports:
        - name: postgres
          containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 30
          periodSeconds: 10
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Gi
```

---

## ⏱️ Point-in-Time Recovery (PITR)

### Understanding PITR

**PITR** lets you restore your database to any moment in time (within your WAL retention).

**How it works**:
1. Restore from base backup (e.g., yesterday's snapshot)
2. Replay Write-Ahead Logs (WAL) up to the desired timestamp
3. Database state at that exact moment is restored

### Implementing PITR

**Step 1: Enable WAL Archiving**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-wal-s3
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: your-key
  AWS_SECRET_ACCESS_KEY: your-secret
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-pitr-config
data:
  recovery.conf: |
    restore_command = 'aws s3 cp "s3://my-backups/wal/%f" "%p"'
    recovery_target_timeline = 'latest'
    recovery_target_xid = '123456'  # Or recovery_target_time = '2025-10-21 15:30:00'
```

**Step 2: Restore to Specific Point**

```bash
# List available WAL files to see recovery window
aws s3 ls s3://my-backups/wal/ --recursive | head -20

# Restore full backup
pg_restore -d mydb < postgres-full-20251020-020000.sql.gz

# WAL files are automatically replayed up to recovery_target_time
```

**Step 3: Verify Recovery**

```bash
# Check database state
psql -d mydb -c "SELECT MAX(created_at) FROM transactions;"

# Verify it matches your target time
```

---

## 🔙 Restore Operations: Bringing Data Back

### Full Restore from Backup

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgres-restore
spec:
  template:
    spec:
      serviceAccountName: postgres-restore
      containers:
      - name: restore
        image: postgres:15
        env:
        - name: PGHOST
          value: postgres-service
        - name: PGUSER
          value: postgres
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: password
        command:
        - /bin/bash
        - -c
        - |
          # Download backup from S3
          BACKUP_FILE="postgres-full-20251020.sql.gz"
          aws s3 cp "s3://my-backups/$BACKUP_FILE" "/tmp/$BACKUP_FILE"
          
          # Drop existing database (CAREFUL!)
          psql -h $PGHOST -U $PGUSER -c "DROP DATABASE mydb;"
          
          # Restore
          zcat "/tmp/$BACKUP_FILE" | psql -h $PGHOST -U $PGUSER
          
          # Verify
          psql -h $PGHOST -U $PGUSER -c "SELECT COUNT(*) FROM information_schema.tables;"
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
      restartPolicy: OnFailure
```

### Selective Restore (Specific Tables)

```bash
# Restore only specific tables
pg_restore -d mydb --table=users < postgres-full-backup.sql.gz

# Restore specific schema
pg_restore -d mydb --schema=public < postgres-full-backup.sql.gz
```

### Restore to Different Database

```bash
# Useful for testing restores without affecting production
pg_restore -d test_restore < backup-file.sql.gz

# Compare schemas
diff <(pg_dump prod_db -s) <(pg_dump test_restore -s)
```

---

## 🚚 Database Migrations: Moving Data Safely

### Migration Strategy: Copy Then Verify

```bash
# Step 1: Dump from old database
pg_dump -h old-postgres-service -U postgres --all > migration.sql.gz

# Step 2: Restore to new database
psql -h new-postgres-service -U postgres < migration.sql.gz

# Step 3: Verify data integrity
# Count rows in old vs new
OLD_COUNT=$(psql -h old-postgres-service -t -c "SELECT COUNT(*) FROM users;")
NEW_COUNT=$(psql -h new-postgres-service -t -c "SELECT COUNT(*) FROM users;")

if [ "$OLD_COUNT" = "$NEW_COUNT" ]; then
  echo "✅ Migration successful: $OLD_COUNT rows"
else
  echo "❌ Migration failed: old=$OLD_COUNT new=$NEW_COUNT"
fi
```

### Dual-Write Strategy (Zero Downtime)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-migration-router
spec:
  selector:
    app: app-server
  type: ClusterIP
  ports:
  - port: 5432
---
# During migration:
# 1. App writes to OLD database
# 2. Start async copy to NEW database
# 3. Verify NEW database is in sync
# 4. Switch app to write to BOTH old and new (dual-write)
# 5. Verify both are in sync
# 6. Switch app to write only to NEW
# 7. Decommission OLD database
```

---

## 🆘 Disaster Recovery Scenarios

### Scenario 1: Corrupted Database

**Symptoms**: Queries fail with corruption errors

**Recovery**:
```bash
# Step 1: Restore from last known good backup
pg_restore -d mydb < last-good-backup.sql.gz

# Step 2: Check backup integrity first
pg_restore -t /dev/null < backup.sql.gz  # Dry run

# Step 3: Verify restored data
SELECT * FROM pg_stat_database WHERE datname='mydb';
```

### Scenario 2: Accidental Data Deletion

**Symptoms**: Data missing, but database seems fine

**Recovery via PITR**:
```bash
# Restore to point just before deletion
# Edit recovery.conf with:
# recovery_target_time = '2025-10-21 14:30:00'  # Before deletion

# Restore and verify
pg_restore < backup.sql.gz
psql -c "SELECT COUNT(*) FROM users;"  # Check if data is back
```

### Scenario 3: Disk Full (PVC at capacity)

**Symptoms**: Database stops accepting writes

**Recovery**:
```bash
# Step 1: Expand PVC
kubectl patch pvc postgres-data -p '{"spec":{"resources":{"requests":{"storage":"200Gi"}}}}'

# Step 2: Trigger resize in storage backend
# (varies by provider, may need manual intervention)

# Step 3: Verify
kubectl describe pvc postgres-data | grep "Capacity"
```

---

## ✅ Testing Your Backups

### Backup Verification Checklist

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-verification
spec:
  schedule: "0 4 * * 0"  # Weekly, Sunday 4 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: verify
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - |
              echo "🔍 Backup Verification Report"
              
              # 1. List recent backups
              echo "📦 Recent backups:"
              aws s3 ls s3://my-backups/postgres/ --recursive | sort | tail -5
              
              # 2. Verify backup file integrity
              echo "🔐 Checking backup integrity..."
              BACKUP_FILE=$(aws s3 ls s3://my-backups/postgres/ | tail -1 | awk '{print $NF}')
              aws s3 cp "s3://my-backups/postgres/$BACKUP_FILE" /tmp/test-backup.sql.gz
              gunzip -t /tmp/test-backup.sql.gz && echo "✅ Backup file is valid"
              
              # 3. Test restore in temporary database
              echo "🧪 Testing restore to temporary database..."
              zcat /tmp/test-backup.sql.gz | psql -c "CREATE DATABASE backup_test;"
              psql -d backup_test -c "SELECT COUNT(*) FROM users;" > /tmp/restore-count.txt
              
              # 4. Compare table counts
              echo "📊 Comparing row counts..."
              PROD_ROWS=$(psql -d mydb -t -c "SELECT COUNT(*) FROM users;")
              TEST_ROWS=$(cat /tmp/restore-count.txt)
              if [ "$PROD_ROWS" = "$TEST_ROWS" ]; then
                echo "✅ Row counts match: $PROD_ROWS"
              else
                echo "❌ Row count mismatch: prod=$PROD_ROWS test=$TEST_ROWS"
              fi
              
              # 5. Cleanup
              psql -c "DROP DATABASE backup_test;"
              rm /tmp/test-backup.sql.gz
          restartPolicy: OnFailure
```

---

## 📊 Monitoring & Alerting

### Key Metrics to Monitor

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-monitoring-alerts
data:
  backup_size: |
    # Alert if backups stop growing (indicates backup failure)
    alert: BackupNotGrowing
    expr: rate(backup_size_bytes[24h]) == 0
    for: 24h
    annotations:
      summary: "Database backup not growing"
      
  wal_archiving_lag: |
    # Alert if WAL archiving falls behind
    alert: WALArchivingLag
    expr: postgres_wal_archiving_lag_seconds > 600
    for: 10m
    annotations:
      summary: "WAL archiving lag exceeds 10 minutes"
      
  disk_usage: |
    # Alert if database disk approaches capacity
    alert: DatabaseDiskFull
    expr: postgres_disk_usage_bytes / postgres_disk_capacity_bytes > 0.85
    for: 1h
    annotations:
      summary: "Database disk 85% full"
```

### Backup Success Logging

```bash
# Log backup success/failure
BACKUP_STATUS=$?
if [ $BACKUP_STATUS -eq 0 ]; then
  echo "✅ Backup successful at $(date)" >> /var/log/backups.log
  # Send success metric to monitoring system
else
  echo "❌ Backup failed at $(date)" >> /var/log/backups.log
  # Send alert to on-call engineer
fi
```

---

## 🎯 Disaster Recovery Plan (DRP) Template

```markdown
## Database Disaster Recovery Plan

### RTO (Recovery Time Objective): 1 hour
### RPO (Recovery Point Objective): 15 minutes

#### Backup Schedule
- Full backups: Daily at 2 AM UTC
- WAL archiving: Continuous (every 5 minutes)
- Snapshots: Hourly via CSI

#### Recovery Procedures
1. Full corruption: Use yesterday's backup + WAL replay (45 min)
2. Point-in-time: Use PITR to 15 min before incident (30 min)
3. Node failure: StatefulSet respawns on new node (5 min)
4. Complete cluster loss: Full restore to new cluster (60 min)

#### Testing
- Monthly: Restore to test environment
- Quarterly: Full DRP drill with team
- Continuously: Automated backup verification

#### Contacts
- On-call DBA: +1-xxx-xxx-xxxx
- Backup admin: backup-admin@company.com
```

---

## 📚 Related Resources

- [Lab 3: Educational Stateful](../../labs/03-educational-stateful.md) — StatefulSets fundamentals
- [Lab 11.5: Disaster Recovery](../../labs/11.5-disaster-recovery.md) — Full DRP implementation
- [Resource Requirements](./resource-requirements.md) — Sizing databases in K8s
- [Production War Stories](./production-war-stories.md) — Real backup failures and how we fixed them

---

**Questions?** [Open an issue](https://github.com/temitayocharles/stack-to-k8s/issues) or check the [Troubleshooting Hub](../40-troubleshooting/troubleshooting-index.md).

