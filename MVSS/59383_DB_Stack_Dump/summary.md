# Summary

## Summary of Key Issues

Here's a concise list of detected issues, with recurring issues highlighted in **bold**:

### Critical Issues
1. **🔴 Assertion Failure in IndexRowScanner.cpp**
   - Location: Line 1056
   - Error: `m_versionStatus.IsVisible()`
   - Occurred across multiple SPIDs (72, 174, 236)
   - Present in all stack dumps

2. **🔴 Memory Pressure**
   - Consistently at 98% MemoryLoad
   - Present across all dumps
   - Likely contributing to other issues

### Secondary Issues
1. Deadlock Detected
   - Between processes accessing `tblPemFutureEvent`
   - Specific to SQLDump0215.log
   - Involved UPDATE operations in `pPem_GetFutureEvents` procedure

2. Failed Login Attempts
   - User: 'alight-com-ad\sadiscoverycomwin'
   - Seen in SQLDump0215.log

### System Context
1. **🔴 Core Components Involved**
   - `sqllang.dll`
   - `sqlmin.dll`
   - `sqldk.dll`
   - `sqlTsEs.dll` (suggesting replication involvement)

2. Environment
   - SQL Server 2017 (14.0.3465.1)
   - Windows Server 2012 R2
   - AWS Infrastructure (Intel Xeon Platinum 8488C)

The most concerning pattern is the combination of the recurring assertion failure and persistent high memory usage, which appears across all dump files and suggests a systemic issue rather than isolated incidents.

Certainly, let's dive deeper into the key issues identified in the summary:

## 1. Assertion Failure in `IndexRowScanner.cpp`

### Technical Details:
- This error is occurring in the `IndexRowScanner` component, which is responsible for scanning and processing index operations in SQL Server.
- The specific assertion failure is at line 1056, where the code is attempting to check the visibility status of a row using the `m_versionStatus.IsVisible()` function.
- This suggests that there is an issue with how SQL Server is managing row visibility during index operations, likely related to transaction isolation levels or row versioning.
- The fact that this error is occurring across multiple sessions (SPIDs 72, 174, 236) indicates a systemic problem, not an isolated incident.

### Potential Causes:
1. **Transaction Isolation Level Conflicts**: The issue with row visibility could be due to a mismatch between the transaction isolation level settings and the expectations of the index operations. This could involve problems with Snapshot Isolation, Read Committed Snapshot Isolation (RCSI), or other transaction management mechanisms.

2. **Row Versioning Challenges**: SQL Server uses row versioning to manage concurrency and data consistency, especially with features like Snapshot Isolation. The assertion failure may indicate issues with how SQL Server is managing or checking the visibility of versioned rows during index operations.

3. **Index Corruption or Metadata Issues**: Although the `DBCC CHECKDB` checks passed, there could be more subtle issues with the index structures or metadata that are not detected by the standard integrity checks, leading to the observed problems.

4. **Replication and Timestamp-based Operations**: The involvement of the `sqlTsEs.dll` component, which is related to transactional replication, suggests that replication or timestamp-based processes may be contributing to the row visibility problems.

### Impact and Implications:
- This assertion failure in a core SQL Server component like `IndexRowScanner` is a critical issue, as it indicates a fundamental problem with how SQL Server is managing data access and consistency during index operations.
- The recurring nature of this error across multiple sessions and dumps suggests a systemic problem that requires in-depth investigation and resolution, as it could lead to broader data integrity and availability issues.

## 2. Memory Pressure

### Technical Details:
- The SQL Server instance is consistently reporting high memory usage, with MemoryLoad at 98% across all the provided dump files.
- High memory pressure can have significant implications for SQL Server's performance and stability, as it can lead to issues with memory management, query execution, and overall system responsiveness.

### Potential Causes:
1. **Insufficient Memory Allocation**: The SQL Server instance may not have been configured with enough available memory to handle the workload and data requirements, leading to the observed memory pressure.

2. **Memory Leaks or Inefficient Memory Usage**: There could be issues with how SQL Server or the application is utilizing memory, potentially due to memory leaks, inefficient queries, or other architectural problems.

3. **Workload Exceeding Available Resources**: If the SQL Server instance is under an unusually high workload, the available memory may not be sufficient to accommodate the required operations, resulting in the observed memory pressure.

### Impact and Implications:
- High memory pressure can significantly impact SQL Server's performance and stability, as it can lead to issues with query execution, index maintenance, and overall data access.
- The memory pressure may also be a contributing factor to the observed assertion failures in the `IndexRowScanner` component, as SQL Server may be making suboptimal decisions about row visibility and index operations due to the memory constraints.

## 3. Deadlock Detected

### Technical Details:
- A deadlock was detected in the `tblPemFutureEvent` table, involving two processes that were waiting for each other's locks.
- The deadlock occurred during an UPDATE operation in the `pPem_GetFutureEvents` stored procedure.

### Potential Causes:
1. **Insufficient Indexing**: The deadlock may be caused by a lack of appropriate indexes on the `tblPemFutureEvent` table, leading to contention and deadlocks during update operations.

2. **Concurrency Issues**: The application or database design may have inherent concurrency problems, where multiple processes are attempting to update the same data or resources without proper locking mechanisms or transaction management.

3. **Suboptimal Query Design**: The `pPem_GetFutureEvents` stored procedure may have issues with how it is accessing and modifying the data, leading to the observed deadlock.

### Impact and Implications:
- Deadlocks can cause application-level failures, data inconsistencies, and significant performance degradation, as they block and interrupt normal database operations.
- The presence of this deadlock, while not as critical as the assertion failure, still indicates an underlying issue that should be addressed to ensure the stability and reliability of the SQL Server instance.

## 4. Failed Login Attempts

### Technical Details:
- The SQL Server error log mentions failed login attempts for the user 'alight-com-ad\sadiscoverycomwin'.

### Potential Causes:
1. **Unauthorized Access Attempts**: The failed login attempts could be indicative of potential security breaches or unauthorized access attempts, which should be investigated further.

2. **Misconfigured Permissions**: There may be issues with the user's permissions or authentication settings, leading to the failed login attempts.

### Impact and Implications:
- While the failed login attempts may not be directly related to the core issues with the `IndexRowScanner` assertion failure and memory pressure, they still represent a potential security concern that should be addressed.
- Investigating the failed login attempts and ensuring proper security measures are in place can help maintain the overall health and integrity of the SQL Server instance.

By understanding these key issues in technical detail, you can better prioritize your troubleshooting efforts, identify potential root causes, and develop a comprehensive plan to address the underlying problems in the SQL Server environment.