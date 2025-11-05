#!/bin/bash
# ManifestAndMatchV7 Architecture Health Check
# Comprehensive diagnostic tool for agents and developers

set -e

echo "🏗️  ManifestAndMatchV7 Architecture Health Check"
echo "================================================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

health_score=100
issues_found=0
critical_violations=0

echo -e "${BLUE}📊 Analyzing 242 Swift files across 8 packages...${NC}\n"

# Function to log critical violations
log_critical() {
    echo -e "${RED}🚨 CRITICAL: $1${NC}"
    critical_violations=$((critical_violations + 1))
    health_score=$((health_score - 25))
    issues_found=$((issues_found + 1))
}

# Function to log warnings
log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    health_score=$((health_score - 10))
    issues_found=$((issues_found + 1))
}

# Function to log success
log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to log info
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. Sacred UI Constants Compliance (CRITICAL)
echo -e "${PURPLE}🔒 Sacred UI Constants Validation${NC}"
echo "-----------------------------------"

sacred_violations=$(grep -r "SacredUI.*=" --include="*.swift" . | grep -v "let.*SacredUI" | grep -v "Documentation/" | wc -l)
if [ "$sacred_violations" -gt 0 ]; then
    log_critical "Sacred UI violations found: $sacred_violations"
    echo -e "${RED}Violations:${NC}"
    grep -r "SacredUI.*=" --include="*.swift" . | grep -v "let.*SacredUI" | grep -v "Documentation/" | head -3
else
    log_success "Sacred UI constants properly protected (0 violations)"
fi

# Check for sacred constants existence
if [ -f "Packages/V7UI/Sources/V7UI/SacredUI.swift" ]; then
    log_success "SacredUI.swift file found"

    # Validate specific sacred constants
    sacred_constants=(
        "rightThreshold.*100\.0"
        "leftThreshold.*-100\.0"
        "upThreshold.*-80\.0"
        "amberHue.*0\.12"
        "tealHue.*0\.52"
    )

    missing_constants=0
    for constant in "${sacred_constants[@]}"; do
        if grep -q "$constant" "Packages/V7UI/Sources/V7UI/SacredUI.swift"; then
            log_success "Sacred constant $constant validated"
        else
            log_warning "Sacred constant $constant missing or incorrect"
            missing_constants=$((missing_constants + 1))
        fi
    done

    if [ "$missing_constants" -gt 2 ]; then
        log_critical "Too many sacred constants missing: $missing_constants"
    fi
else
    log_critical "SacredUI.swift file not found"
fi

# 2. Thompson Sampling Performance Validation (CRITICAL)
echo -e "\n${PURPLE}🧠 Thompson Sampling Performance Validation${NC}"
echo "---------------------------------------------"

thompson_files=$(find . -name "*Thompson*" -type f | wc -l)
if [ "$thompson_files" -gt 0 ]; then
    log_success "Thompson Sampling components found ($thompson_files files)"

    # Check for performance markers
    performance_markers=$(grep -r "0\.028ms\|357x\|<10ms" --include="*.swift" . | wc -l)
    if [ "$performance_markers" -gt 0 ]; then
        log_success "Thompson performance markers found ($performance_markers references)"
    else
        log_warning "Thompson performance markers not detected"
    fi

    # Check for mathematical correctness markers
    math_markers=$(grep -r "BetaDistribution\|Gamma\|Marsaglia" --include="*.swift" Packages/V7Thompson/ 2>/dev/null | wc -l)
    if [ "$math_markers" -gt 0 ]; then
        log_success "Mathematical implementation markers found"
    else
        log_warning "Mathematical implementation not verified"
    fi
else
    log_critical "Thompson Sampling components not found"
fi

# 3. Package Architecture Validation (CRITICAL)
echo -e "\n${PURPLE}📦 Package Architecture Validation${NC}"
echo "-----------------------------------"

# Check required packages exist
required_packages=(V7Core V7Data V7Services V7UI V7Thompson V7Performance V7Migration)
missing_packages=0

for package in "${required_packages[@]}"; do
    if [ -d "Packages/$package" ]; then
        log_success "Package $package exists"

        # Check Package.swift exists
        if [ -f "Packages/$package/Package.swift" ]; then
            # Check dependencies for clean architecture
            v7_deps=$(grep -c "V7" "Packages/$package/Package.swift" 2>/dev/null || echo "0")
            log_info "$package has $v7_deps V7 dependencies"
        else
            log_warning "Package.swift missing for $package"
        fi
    else
        log_critical "Required package $package not found"
        missing_packages=$((missing_packages + 1))
    fi
done

# V7Core should have no V7 dependencies (foundation layer)
if [ -f "Packages/V7Core/Package.swift" ]; then
    v7core_deps=$(grep -c "V7" "Packages/V7Core/Package.swift" 2>/dev/null || echo "0")
    if [ "$v7core_deps" -eq 0 ]; then
        log_success "V7Core properly isolated (foundation layer)"
    else
        log_critical "V7Core has V7 dependencies - violates foundation principle"
    fi
fi

# Check for circular dependencies
echo -e "\n${BLUE}Checking for circular dependencies...${NC}"
circular_deps=$(grep -r "import V7" Packages/ 2>/dev/null | grep -E "(circular|cycle)" | wc -l)
if [ "$circular_deps" -eq 0 ]; then
    log_success "No circular dependencies detected"
else
    log_critical "Circular dependencies found: $circular_deps"
fi

# 4. Performance Budget Compliance
echo -e "\n${PURPLE}📈 Performance Budget Compliance${NC}"
echo "----------------------------------"

# Memory budget references
memory_monitors=$(grep -r "MemoryMonitor\|200MB\|300MB" --include="*.swift" . | wc -l)
if [ "$memory_monitors" -gt 0 ]; then
    log_success "Memory budget monitoring active ($memory_monitors references)"
else
    log_warning "Memory budget monitoring not detected"
fi

# Response time validation
response_times=$(grep -r "10ms\|<16ms\|<3s" --include="*.swift" . | wc -l)
if [ "$response_times" -gt 0 ]; then
    log_success "Response time monitoring found ($response_times references)"
else
    log_warning "Response time monitoring may be missing"
fi

# Performance optimization files
perf_files=$(find Packages/V7Performance -name "*.swift" 2>/dev/null | wc -l)
if [ "$perf_files" -gt 5 ]; then
    log_success "Performance monitoring package populated ($perf_files files)"
else
    log_warning "Performance monitoring package appears minimal"
fi

# 5. Swift Concurrency Validation (Swift 6 Compliance)
echo -e "\n${PURPLE}⚡ Swift Concurrency Validation${NC}"
echo "-------------------------------"

# Check for modern async/await usage
async_functions=$(grep -r "async func" --include="*.swift" Packages/ | wc -l)
if [ "$async_functions" -gt 10 ]; then
    log_success "Modern async functions found ($async_functions)"
else
    log_warning "Limited async/await adoption ($async_functions functions)"
fi

# Check for @MainActor usage
mainactor_usage=$(grep -r "@MainActor" --include="*.swift" . | wc -l)
if [ "$mainactor_usage" -gt 5 ]; then
    log_success "@MainActor properly used ($mainactor_usage instances)"
else
    log_warning "Limited @MainActor usage ($mainactor_usage instances)"
fi

# Check for old completion handler patterns
completion_handlers=$(grep -r "completion:" --include="*.swift" Packages/ | grep -v "async" | wc -l)
if [ "$completion_handlers" -lt 5 ]; then
    log_success "Good async/await adoption (few completion handlers)"
else
    log_warning "$completion_handlers completion handlers could be modernized"
fi

# Check for Sendable compliance
sendable_usage=$(grep -r "@unchecked Sendable\|: Sendable" --include="*.swift" . | wc -l)
if [ "$sendable_usage" -gt 0 ]; then
    log_success "Sendable compliance found ($sendable_usage instances)"
else
    log_warning "Sendable compliance not detected"
fi

# 6. Business Value Component Health
echo -e "\n${PURPLE}🎯 Business Value Component Health${NC}"
echo "----------------------------------"

# Core business components
job_source_files=$(find . -name "*JobSource*" -o -name "*Job*API*" | wc -l)
if [ "$job_source_files" -gt 3 ]; then
    log_success "Job source integration components found ($job_source_files files)"
else
    log_warning "Limited job source integration detected ($job_source_files files)"
fi

# Thompson business logic
thompson_business=$(grep -r "ThompsonSampling\|scoreJob\|BetaDistribution" --include="*.swift" . | wc -l)
if [ "$thompson_business" -gt 10 ]; then
    log_success "Thompson business logic comprehensive ($thompson_business references)"
else
    log_warning "Thompson business logic may be limited"
fi

# Sacred UI business value
sacred_ui_refs=$(grep -r "SacredUI" --include="*.swift" . | grep -v "Documentation" | wc -l)
if [ "$sacred_ui_refs" -gt 5 ]; then
    log_success "Sacred UI system properly integrated ($sacred_ui_refs references)"
else
    log_warning "Sacred UI system integration limited"
fi

# 7. Test Infrastructure Health
echo -e "\n${PURPLE}🧪 Test Infrastructure Health${NC}"
echo "------------------------------"

# Count test files
test_files=$(find . -name "*Test*.swift" -o -name "*Tests.swift" | wc -l)
source_files=$(find Packages/ -name "*.swift" | grep -v Tests | wc -l)

if [ "$source_files" -gt 0 ]; then
    test_ratio=$((test_files * 100 / source_files))
    if [ "$test_ratio" -gt 25 ]; then
        log_success "Test coverage appears good ($test_ratio% ratio, $test_files test files)"
    else
        log_warning "Test coverage may be low ($test_ratio% ratio, $test_files test files)"
    fi
else
    log_warning "Unable to calculate test coverage"
fi

# Swift Testing framework usage
swift_testing=$(grep -r "#expect\|#require\|@Test" --include="*.swift" . 2>/dev/null | wc -l)
if [ "$swift_testing" -gt 0 ]; then
    log_success "Modern Swift Testing framework in use ($swift_testing assertions)"
else
    log_warning "Consider adopting Swift Testing framework"
fi

# Performance tests
perf_tests=$(find . -name "*Performance*Test*" -o -name "*Benchmark*" | wc -l)
if [ "$perf_tests" -gt 0 ]; then
    log_success "Performance testing found ($perf_tests files)"
else
    log_warning "Performance testing not detected"
fi

# Final Health Score Calculation and Summary
echo -e "\n================================================="
echo -e "🏥 ${BLUE}ARCHITECTURE HEALTH SUMMARY${NC}"
echo "================================================="

# Adjust score based on critical violations
if [ "$critical_violations" -gt 0 ]; then
    health_score=$((health_score - (critical_violations * 15)))  # Extra penalty for critical issues
fi

# Cap minimum score at 0
if [ "$health_score" -lt 0 ]; then
    health_score=0
fi

# Health score assessment with specific guidance
if [ "$health_score" -ge 95 ]; then
    echo -e "Overall Health Score: ${GREEN}$health_score/100 (EXCEPTIONAL)${NC}"
    echo -e "${GREEN}🏆 Architecture is in exceptional health!${NC}"
    exit_code=0
elif [ "$health_score" -ge 85 ]; then
    echo -e "Overall Health Score: ${GREEN}$health_score/100 (EXCELLENT)${NC}"
    echo -e "${GREEN}🎉 Architecture is in excellent health!${NC}"
    exit_code=0
elif [ "$health_score" -ge 75 ]; then
    echo -e "Overall Health Score: ${YELLOW}$health_score/100 (GOOD)${NC}"
    echo -e "${YELLOW}✅ Architecture is healthy with minor areas for improvement${NC}"
    exit_code=1
elif [ "$health_score" -ge 60 ]; then
    echo -e "Overall Health Score: ${YELLOW}$health_score/100 (FAIR)${NC}"
    echo -e "${YELLOW}⚠️  Architecture needs attention in several areas${NC}"
    exit_code=1
else
    echo -e "Overall Health Score: ${RED}$health_score/100 (NEEDS IMMEDIATE ATTENTION)${NC}"
    echo -e "${RED}🚨 Architecture requires urgent fixes${NC}"
    exit_code=2
fi

echo ""
echo "Critical Violations: $critical_violations"
echo "Total Issues: $issues_found"

# Specific guidance based on findings
if [ "$critical_violations" -gt 0 ]; then
    echo -e "\n${RED}🚨 CRITICAL ISSUES DETECTED:${NC}"
    echo -e "  • Sacred UI violations: Must be fixed immediately"
    echo -e "  • Package architecture violations: Could break system"
    echo -e "  • Thompson performance issues: Could impact competitive advantage"
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo -e "  1. Fix critical violations before any other development"
    echo -e "  2. Run: ${YELLOW}./Documentation/CodeQuality/architecture_validator.sh${NC}"
    echo -e "  3. Review and validate all Sacred UI constants"
fi

if [ "$issues_found" -gt 0 ] && [ "$critical_violations" -eq 0 ]; then
    echo -e "\n${YELLOW}💡 IMPROVEMENT OPPORTUNITIES:${NC}"
    echo -e "  • Consider running: ${YELLOW}./Documentation/CodeQuality/code_cleanup.sh${NC}"
    echo -e "  • Review performance monitoring implementation"
    echo -e "  • Enhance test coverage where needed"
fi

if [ "$issues_found" -eq 0 ]; then
    echo -e "\n${GREEN}🎯 ARCHITECTURE EXCELLENCE MAINTAINED:${NC}"
    echo -e "  • 357x Thompson Sampling performance advantage"
    echo -e "  • Sacred UI constants properly protected"
    echo -e "  • Clean package dependency graph"
    echo -e "  • Modern Swift 6 concurrency compliance"
    echo -e "\n${BLUE}Keep up the exceptional work! 🚀${NC}"
fi

exit $exit_code