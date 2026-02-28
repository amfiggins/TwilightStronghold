## 2024-05-26 - O(1) Array Removal (Swap-Remove)

**Learning:** Removing elements from the middle of arrays using `table.remove` in Lua forces an O(N) operation to shift all subsequent elements to the left. In high-frequency systems like inventory management or large loops, this creates unnecessary CPU overhead. Furthermore, shifting indices invalidates lookup maps, forcing expensive full re-evaluations (e.g., `rebuildLookup`).
**Action:** Replace `table.remove` with an O(1) "Swap-Remove" approach where the element to be removed is overwritten by the last element of the array, and the last index is then set to `nil`. This requires managing lookup map indices dynamically (e.g., updating the moved element's map index).
