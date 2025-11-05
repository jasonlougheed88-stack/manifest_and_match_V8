#!/bin/bash

# Test Adzuna API with actual credentials
APP_ID="b1d71459"
APP_KEY="c0dd918ac38cf3d5e022e18b7375ed7d"

echo "🧪 Testing Adzuna API with your credentials..."
echo ""

# Test 1: Simple job search (sales in Remote)
echo "Test 1: Searching for 'sales' jobs in 'Remote'"
RESPONSE=$(curl -s "https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=${APP_ID}&app_key=${APP_KEY}&results_per_page=5&what=sales&where=Remote")

# Check if response contains results
if echo "$RESPONSE" | grep -q "\"count\""; then
    COUNT=$(echo "$RESPONSE" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    RESULTS=$(echo "$RESPONSE" | grep -o '"results":\[' | wc -l)
    echo "✅ API working! Total jobs available: $COUNT"
    echo "   Jobs returned: $(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | wc -l)"
else
    echo "❌ API error:"
    echo "$RESPONSE" | head -20
fi

echo ""
echo "---"
echo ""

# Test 2: Broader search (sales anywhere)
echo "Test 2: Searching for 'sales' jobs anywhere in US"
RESPONSE2=$(curl -s "https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=${APP_ID}&app_key=${APP_KEY}&results_per_page=10&what=sales")

if echo "$RESPONSE2" | grep -q "\"count\""; then
    COUNT2=$(echo "$RESPONSE2" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    echo "✅ API working! Total jobs available: $COUNT2"
    echo "   Jobs returned: $(echo "$RESPONSE2" | grep -o '"id":"[^"]*"' | wc -l)"

    # Show first job title
    FIRST_TITLE=$(echo "$RESPONSE2" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"//;s/"//')
    echo "   Example job: $FIRST_TITLE"
else
    echo "❌ API error:"
    echo "$RESPONSE2" | head -20
fi

echo ""
echo "---"
echo ""

# Test 3: Check API quota/rate limit
echo "Test 3: Checking API credentials validity"
HEALTH=$(curl -s "https://api.adzuna.com/v1/api/jobs/us/search/1?app_id=${APP_ID}&app_key=${APP_KEY}&results_per_page=1&what=test")

if echo "$HEALTH" | grep -q "\"count\""; then
    echo "✅ Credentials valid and working"
else
    echo "❌ Credentials issue:"
    echo "$HEALTH"
fi

echo ""
echo "📊 Summary:"
echo "   Credentials: $APP_ID / ${APP_KEY:0:8}..."
echo "   Endpoint: https://api.adzuna.com/v1/api/jobs/us/search/1"
