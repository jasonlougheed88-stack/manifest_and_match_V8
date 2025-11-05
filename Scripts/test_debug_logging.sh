#!/bin/bash

# Script to test debug logging functionality
# This demonstrates all the different debug log formats

echo "=========================================="
echo "V7 Debug Logging Test Script"
echo "=========================================="
echo ""

# Test 1: Mock fallback enabled (default behavior)
echo "TEST 1: Default behavior with mock fallback"
echo "--------------------------------------------"
export DEBUG_JOB_SOURCES=true
export ENABLE_PERFORMANCE_METRICS=true
unset BLOCK_MOCK_FALLBACK
unset INDEED_API_KEY
unset INDEED_PUBLISHER_ID

echo "Environment:"
echo "  DEBUG_JOB_SOURCES=true"
echo "  BLOCK_MOCK_FALLBACK=(not set, defaults to false)"
echo "  INDEED_API_KEY=(not set)"
echo ""
echo "Expected output:"
echo "  🔧 JobSourceManager: Mock fallback = true"
echo "  📋 Registered sources: 1 (mock)"
echo "  🔗 Available sources: MockJobSource"
echo "  🔍 Fetching from: mock"
echo "  ✅ Success: 20 jobs in ~500ms"
echo "  📊 Job Source Used: mock - 20 jobs"
echo "  ⚡ Mock API: ~500ms (✅ <1000ms target)"
echo "  🎯 Thompson Scoring: <0.148ms (✅ target met)"
echo "  📈 Total Pipeline: <5000ms (✅ <5s target)"
echo ""

# Test 2: Mock blocked, no Indeed credentials
echo "TEST 2: Mock blocked without Indeed credentials"
echo "-----------------------------------------------"
export BLOCK_MOCK_FALLBACK=true

echo "Environment:"
echo "  DEBUG_JOB_SOURCES=true"
echo "  BLOCK_MOCK_FALLBACK=true"
echo "  INDEED_API_KEY=(not set)"
echo ""
echo "Expected output:"
echo "  🔧 JobSourceManager: Mock fallback = false"
echo "  ⚠️ Mock fallback blocked and no Indeed API credentials available"
echo "  📋 No fallback available (mock blocked)"
echo "  📋 Registered sources: 0 ()"
echo ""

# Test 3: Real Indeed API
echo "TEST 3: Real Indeed API (requires valid credentials)"
echo "----------------------------------------------------"
export INDEED_API_KEY="your-api-key-here"
export INDEED_PUBLISHER_ID="your-publisher-id-here"
export BLOCK_MOCK_FALLBACK=true

echo "Environment:"
echo "  DEBUG_JOB_SOURCES=true"
echo "  BLOCK_MOCK_FALLBACK=true"
echo "  INDEED_API_KEY=(set)"
echo "  INDEED_PUBLISHER_ID=(set)"
echo ""
echo "Expected output:"
echo "  🔧 JobSourceManager: Mock fallback = false"
echo "  📋 Registered sources: 1 (indeed)"
echo "  🔗 Available sources: IndeedAPIClient"
echo "  🔍 Fetching from: indeed"
echo "  ✅ Success: 25 jobs in 2.43ms"
echo "  📊 Job Source Used: indeed - 25 jobs"
echo "  ⚡ Indeed API: 2.43ms (✅ <3ms target)"
echo "  🎯 Thompson Scoring: 0.148ms (✅ target met)"
echo "  📈 Total Pipeline: 4.82ms (✅ <5ms target)"
echo ""

# Test 4: Error scenarios
echo "TEST 4: Error and fallback scenarios"
echo "------------------------------------"
echo ""
echo "Network timeout:"
echo "  ⚠️ Indeed API failed: Network timeout"
echo ""
echo "Circuit breaker open:"
echo "  🔄 Circuit breaker: OPEN"
echo "  📋 No fallback available (mock blocked)"
echo ""
echo "Rate limit exceeded:"
echo "  ⚠️ Indeed API rate limit exceeded, resets at: [timestamp]"
echo ""

# Test 5: Performance alerts
echo "TEST 5: Performance monitoring"
echo "------------------------------"
echo ""
echo "When performance targets are exceeded:"
echo "  ⚡ Indeed API: 5.43ms (⚠️ <3ms target)"
echo "  🎯 Thompson Scoring: 0.248ms (⚠️ target met)"
echo "  📈 Total Pipeline: 8.82ms (⚠️ <5ms target)"
echo "  ⚠️ Performance budget exceeded:"
echo "    - Response time: 0.248ms (target: <0.148ms)"
echo "    - Last fetch: 8.82ms (target: <5000ms)"
echo ""

echo "=========================================="
echo "To run the actual app with debug logging:"
echo "=========================================="
echo ""
echo "# Enable all debug logging:"
echo "export DEBUG_JOB_SOURCES=true"
echo "export ENABLE_PERFORMANCE_METRICS=true"
echo ""
echo "# Test with mock data:"
echo "export BLOCK_MOCK_FALLBACK=false"
echo ""
echo "# Test with real Indeed API:"
echo "export BLOCK_MOCK_FALLBACK=true"
echo "export INDEED_API_KEY='your-key'"
echo "export INDEED_PUBLISHER_ID='your-id'"
echo ""
echo "# Then run your app or tests"
echo ""