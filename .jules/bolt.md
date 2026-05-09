## 2024-05-17 - Fast Distance Checking
**Learning:** Checking distance against a constant threshold using `.Magnitude` runs an unnecessary and expensive `math.sqrt` operation per call, which adds up fast in entity loop updates.
**Action:** Replace `.Magnitude` checks against thresholds with an explicit squared distance calculation (e.g., `dx*dx + dy*dy + dz*dz < threshold*threshold`) to skip the bridge crossing to C++ math.sqrt while keeping the identical logical result.
