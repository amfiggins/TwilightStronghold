## 2024-05-18 - Prevent DoS and Memory Leaks in RemoteEvents
**Vulnerability:** RemoteEvents lacking rate limiting and using `warn()` can be spammed by malicious clients to cause log-flooding and DoS. Memory leaks can also occur if user tracking tables aren't cleared on disconnect.
**Learning:** Security-critical rate limiting must prefer silent returns (e.g., `false, "RateLimited"`) over `warn()` logging to avoid log-flooding vulnerabilities. Additionally, any per-user tracking table requires a cleanup handler connected to `Players.PlayerRemoving`.
**Prevention:** Always implement rate limiting on RemoteEvents, avoid logging arbitrary data on validation failure to prevent log spamming, and bind memory cleanup to `PlayerRemoving`.
