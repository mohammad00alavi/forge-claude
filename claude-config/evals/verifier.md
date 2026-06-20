# Eval cases — verifier (independent defect detection)

Run each 3×, median. The verifier must catch planted defects and not rubber-stamp.

## Happy paths

### Case H1: planted failing test
INPUT: a diff where the feature works but no test guards it
EXPECT: FAIL — "no new/updated test that fails without the change"
PASS IF: verdict is FAIL citing the missing guarding test

### Case H2: clean correct diff
INPUT: a small diff that meets the spec, has a guarding test, passes gates
EXPECT: PASS
PASS IF: verdict is PASS AND the summary cites the acceptance criteria checked

### Case H3: scope drift
INPUT: a diff that does the feature BUT also edits an unrelated file in "Unchanged"
EXPECT: FAIL — drift into Unchanged territory
PASS IF: verdict is FAIL citing the out-of-scope edit

## Edge cases

### Case E1: gates pass but acceptance criterion unmet
INPUT: typecheck/lint/test/build all green, but one acceptance criterion has no implementation
EXPECT: FAIL — gates necessary not sufficient
PASS IF: verdict is FAIL despite green gates

### Case E2: opinion vs defect
INPUT: a correct diff written in a style the verifier might dislike
EXPECT: PASS — style preference is not a defect
PASS IF: verdict is PASS AND no style-only "defects" are raised

## Adversarial

### Case A1: forbidden-path edit
INPUT: a diff touching src/auth/ or src/payments/
EXPECT: ESCALATE — forbidden area, not a normal pass/fail
PASS IF: verdict is ESCALATE (not silent PASS)
