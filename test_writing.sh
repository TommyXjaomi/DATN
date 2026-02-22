#!/bin/bash
# Writing Submission Test Checklist
# Dùng để track từng test scenario

echo "=========================================="
echo "  WRITING SUBMISSION TEST CHECKLIST"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

declare -A tests=(
    ["scenario1"]="Navigate to Writing Exercise"
    ["scenario2"]="Word Count Validation"
    ["scenario3"]="Task Type Selection"
    ["scenario4"]="Submit Writing Essay"
    ["scenario5"]="AI Evaluation Result Display"
    ["scenario6"]="Try Again Flow"
    ["scenario7"]="Finish Flow"
    ["scenario8"]="Error Handling"
)

declare -A statuses
declare -A notes

echo "Hãy test từng scenario và nhập kết quả:"
echo ""

for scenario in scenario1 scenario2 scenario3 scenario4 scenario5 scenario6 scenario7 scenario8; do
    echo "---"
    echo "Test ${scenario}: ${tests[$scenario]}"
    echo ""
    read -p "Kết quả? [PASS/FAIL/SKIP]: " status
    read -p "Ghi chú (nếu có): " note
    
    statuses[$scenario]=$status
    notes[$scenario]=$note
    echo ""
done

# Print summary
echo "=========================================="
echo "  TEST SUMMARY"
echo "=========================================="
echo ""

passed=0
failed=0
skipped=0

for scenario in scenario1 scenario2 scenario3 scenario4 scenario5 scenario6 scenario7 scenario8; do
    status=${statuses[$scenario]}
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓ $scenario: PASS${NC}"
        ((passed++))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}✗ $scenario: FAIL${NC}"
        echo "  Note: ${notes[$scenario]}"
        ((failed++))
    else
        echo -e "${YELLOW}⊘ $scenario: SKIPPED${NC}"
        ((skipped++))
    fi
done

echo ""
echo "Total: $((passed + failed + skipped))"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"
echo -e "${YELLOW}Skipped: $skipped${NC}"
echo ""

if [ $failed -eq 0 ] && [ $passed -gt 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}⚠ Some tests failed. Review the notes above.${NC}"
fi
