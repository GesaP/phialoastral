# Performance Check v3 Migration Guide

## Overview

Performance Check v3 represents a major enhancement to our Lighthouse CI implementation, addressing all requirements from issue #421:

1. ✅ **Enhanced PR comment formatting** with comprehensive metrics display
2. ✅ **Mobile and desktop viewport testing** run in parallel
3. ✅ **Multi-page testing** for all key pages (10 URLs total)
4. ✅ **Multilingual support** testing both German and English versions
5. ✅ **Performance budgets** with graduated failure conditions
6. ✅ **Core Web Vitals focus** with clear visual indicators

## Key Improvements Over v2

### 🎯 What's New in v3

#### 1. Dual Viewport Testing
- **Mobile Testing**: Simulates real mobile conditions with 4x CPU throttling
- **Desktop Testing**: Full desktop viewport with minimal throttling
- **Parallel Execution**: Both viewports tested simultaneously for faster results
- **Device-Specific Budgets**: Different thresholds for mobile vs desktop

#### 2. Enhanced PR Comment Format
```markdown
## 🚀 Lighthouse Performance Report

### ✅ Excellent - Overall Score: 92/100

**Preview URL:** phialo-pr-123
**Test Date:** 2025-01-27

### 📊 Core Web Vitals Summary

| Metric | Desktop | Mobile | Status | Target |
|--------|---------|--------|--------|--------|
| **LCP** | 1.8s | 2.4s | 🟢 | ≤2.5s |
| **CLS** | 0.05 | 0.08 | 🟢 | ≤0.1 |
| **INP** | 150ms | 280ms | 🟡 | ≤200ms |
| **FCP** | 0.9s | 1.5s | 🟢 | ≤1.8s |

<details>
<summary><b>📱 Performance by Device & Page</b></summary>
[Detailed metrics per page]
</details>
```

#### 3. Comprehensive Testing Coverage
- **10 URLs tested**: Home, Portfolio, Services, About, Contact (German + English)
- **3 runs per URL**: Median values used for stability
- **30 total Lighthouse runs**: Comprehensive coverage

#### 4. Smart Performance Budgets
```javascript
// Desktop Budgets
'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
'cumulative-layout-shift': ['warn', { maxNumericValue: 0.1 }],
'total-blocking-time': ['error', { maxNumericValue: 300 }],

// Mobile Budgets (more lenient)
'largest-contentful-paint': ['error', { maxNumericValue: 4000 }],
'cumulative-layout-shift': ['warn', { maxNumericValue: 0.25 }],
'total-blocking-time': ['error', { maxNumericValue: 600 }],
```

#### 5. Action Items Generation
- Automatically identifies performance issues
- Provides specific recommendations
- Groups issues by severity

## Workflow Architecture

### Parallel Job Structure
```yaml
jobs:
  performance-check-mobile:    # Runs mobile tests
  performance-check-desktop:   # Runs desktop tests (parallel)
  generate-report:            # Combines results and posts comment
```

### Execution Flow
1. **Trigger**: After successful deployment or manual dispatch
2. **Mobile Job**: Tests all URLs with mobile settings
3. **Desktop Job**: Tests all URLs with desktop settings (parallel)
4. **Report Job**: Waits for both, generates combined report
5. **PR Comment**: Posts/updates comprehensive results

## Migration Steps

### Phase 1: Testing (Current)
```bash
# Test the new workflow on a PR
gh workflow run performance-check-v3.yml -f pr_number=123

# Test with specific viewport
gh workflow run performance-check-v3.yml -f pr_number=123 -f viewport=mobile
```

### Phase 2: Validation
1. Compare v3 results with v2 on same PR
2. Verify mobile/desktop scores are appropriate
3. Check report formatting and clarity
4. Validate performance budget thresholds

### Phase 3: Gradual Rollout
1. Run v3 alongside v2 for 1 week
2. Monitor for false positives
3. Adjust budgets based on real data
4. Gather developer feedback

### Phase 4: Full Migration
1. Update deployment workflows to trigger v3
2. Disable v2 workflow
3. Archive v2 configuration
4. Update documentation

### Phase 5: Cleanup
```bash
# Disable old workflows
mv .github/workflows/performance-check-v2.yml .github/workflows/performance-check-v2.yml.archived
mv .github/workflows/performance-check.yml.disabled .github/workflows/performance-check.yml.archived

# Rename v3 to standard name
mv .github/workflows/performance-check-v3.yml .github/workflows/performance-check.yml
```

## Configuration Details

### Mobile Configuration
```javascript
{
  preset: 'mobile',
  formFactor: 'mobile',
  throttling: {
    rttMs: 150,              // 3G network latency
    throughputKbps: 1638,    // 3G network speed
    cpuSlowdownMultiplier: 4 // Simulate slower mobile CPU
  },
  screenEmulation: {
    mobile: true,
    width: 390,              // iPhone 14 Pro width
    height: 844,             // iPhone 14 Pro height
    deviceScaleFactor: 3
  }
}
```

### Desktop Configuration
```javascript
{
  preset: 'desktop',
  formFactor: 'desktop',
  throttling: {
    rttMs: 40,               // Cable network latency
    throughputKbps: 10240,   // 10 Mbps
    cpuSlowdownMultiplier: 1 // No CPU throttling
  },
  screenEmulation: {
    mobile: false,
    width: 1350,             // Standard desktop width
    height: 940,
    deviceScaleFactor: 1
  }
}
```

## Performance Budgets

### Error Thresholds (Fail CI)
| Metric | Desktop | Mobile | Rationale |
|--------|---------|--------|-----------|
| FCP | 2000ms | 3000ms | User sees content quickly |
| LCP | 2500ms | 4000ms | Main content loads fast |
| TBT | 300ms | 600ms | Page stays responsive |
| TTI | 3800ms | 5300ms | Page becomes interactive |

### Warning Thresholds (Report Only)
| Metric | Desktop | Mobile | Rationale |
|--------|---------|--------|-----------|
| CLS | 0.1 | 0.25 | Visual stability |
| Performance Score | 85 | 75 | Overall quality |
| Accessibility | 93 | 90 | Inclusive design |
| SEO | 95 | 95 | Search visibility |

### Resource Budgets
| Resource | Desktop | Mobile | Notes |
|----------|---------|--------|-------|
| JavaScript | 1000KB | 1200KB | All JS bundles |
| CSS | 75KB | 100KB | All stylesheets |
| Images | 1100KB | 1500KB | Per page |
| Total | 2500KB | 3000KB | Full page weight |

## Testing the New Workflow

### Manual Testing Commands
```bash
# Test both viewports on a PR
gh workflow run performance-check-v3.yml \
  -f pr_number=123 \
  -f viewport=both

# Test mobile only
gh workflow run performance-check-v3.yml \
  -f pr_number=123 \
  -f viewport=mobile

# Test desktop only
gh workflow run performance-check-v3.yml \
  -f pr_number=123 \
  -f viewport=desktop

# Test local build (debugging)
gh workflow run performance-check-v3.yml \
  -f pr_number=123 \
  -f test_local=true
```

### Validation Checklist
- [ ] Mobile scores are 10-15 points lower than desktop (expected)
- [ ] All 10 URLs are tested successfully
- [ ] PR comment formatting is clear and actionable
- [ ] Performance budgets trigger appropriately
- [ ] Action items are relevant and helpful
- [ ] Artifacts are uploaded for both viewports
- [ ] Workflow completes in under 10 minutes

## Troubleshooting

### Issue: Workflow Takes Too Long
**Solution**: Reduce `numberOfRuns` from 3 to 2 in configs

### Issue: False Positive Failures
**Solution**: Adjust budget thresholds based on baseline data

### Issue: Missing Mobile/Desktop Results
**Solution**: Check job conditions and ensure both jobs run

### Issue: PR Comment Not Appearing
**Solution**: Verify `pull-requests: write` permission is set

## Benefits Over Previous Versions

### v1 → v2 Improvements
- Tests deployed URLs instead of localhost
- Waits for deployment completion
- Collapsible report sections

### v2 → v3 Improvements
- **2x Coverage**: Mobile + Desktop testing
- **Better UX**: Enhanced visual indicators
- **Actionable**: Specific improvement recommendations
- **Comprehensive**: All pages, both languages
- **Reliable**: Parallel execution, median of 3 runs
- **Graduated Failures**: Errors vs warnings

## Performance Impact

### Expected Metrics
| Metric | v2 | v3 | Change |
|--------|-----|-----|--------|
| Total Tests | 30 | 60 | +100% |
| Execution Time | ~5 min | ~8 min | +60% |
| Report Detail | Basic | Comprehensive | +200% |
| Actionability | Low | High | Significant |

### Resource Usage
- **GitHub Actions Minutes**: ~16 minutes per run (2 parallel jobs)
- **Lighthouse CI Storage**: Temporary (7-day retention)
- **Artifact Storage**: ~20MB per run

## Next Steps

### Immediate (Week 1)
1. Deploy v3 workflow to repository
2. Test on 3-5 active PRs
3. Gather initial feedback
4. Adjust budgets if needed

### Short Term (Week 2-3)
1. Run v3 alongside v2
2. Compare results consistency
3. Fine-tune thresholds
4. Update team documentation

### Long Term (Month 2+)
1. Implement historical tracking
2. Add baseline comparison
3. Create performance dashboard
4. Set up alerting for regressions

## Future Enhancements

### Planned for v4
- **Baseline Comparison**: Compare PR vs master metrics
- **Historical Tracking**: Store results in database
- **Trend Analysis**: Show performance over time
- **Custom Metrics**: Business-specific measurements
- **Visual Regression**: Screenshot comparisons

### Under Consideration
- Third-party script analysis
- Bundle size tracking
- Critical CSS coverage
- Accessibility deep-dive mode
- Security header validation

## Support

For issues or questions:
- Create issue with `performance-check-v3` label
- Check [workflow logs](https://github.com/barde/phialoastro/actions)
- Review this guide for troubleshooting
- Contact @devops-team for urgent issues

## Related Documentation

- [Lighthouse CI Documentation](https://github.com/GoogleChrome/lighthouse-ci)
- [Core Web Vitals](https://web.dev/vitals/)
- [GitHub Actions Matrix](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Performance Budgets](https://web.dev/performance-budgets-101/)