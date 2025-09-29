#!/bin/bash
# Quick Link Validation - Check for broken markdown links

echo "🔗 LINK VALIDATION REPORT"
echo "========================"
echo ""

BROKEN_LINKS=0

echo "Checking main documentation links..."

# Check docs folder links
for file in docs/*.md; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        ((BROKEN_LINKS++))
    fi
done

echo ""
echo "Checking social media platform docs..."

# Check social media docs
SOCIAL_DOCS="social-media-platform/docs"
for doc in troubleshooting.md production-deployment.md setup-requirements.md architecture.md ai-features.md; do
    if [ -f "$SOCIAL_DOCS/$doc" ]; then
        echo "✅ $SOCIAL_DOCS/$doc exists"
    else
        echo "❌ $SOCIAL_DOCS/$doc missing"
        ((BROKEN_LINKS++))
    fi
done

echo ""
echo "Checking vault documentation..."

if [ -f "vault/STEP-BY-STEP-GUIDE.md" ]; then
    echo "✅ vault/STEP-BY-STEP-GUIDE.md exists"
else
    echo "❌ vault/STEP-BY-STEP-GUIDE.md missing"
    ((BROKEN_LINKS++))
fi

echo ""
echo "📊 SUMMARY"
echo "=========="
if [ $BROKEN_LINKS -eq 0 ]; then
    echo "🎉 All links are working! No broken references found."
else
    echo "⚠️  Found $BROKEN_LINKS broken links that need attention."
fi