# MVSS-59383 | Stack dump was thrown on LNPRODT Server.

> On 10/22/2024 02:23:05 a stack dump was thrown on LNPRODT, attached the log locations.  Please review and identify if issue is data related.  Confirmed DBCC CHECKDB is successful.

## Contents

1. Initial Message
   - [Initial Message](#initial-message)
2. [System Summary](#system-summary)
3. Logs Provided
   - [sqldump0214log](#sqldump0214log)
   - [sqldump0215log](#sqldump0215log)
   - [SQLDump0215.txt](#sqldump0215txt)
   - [SQLDump0216.txt](#sqldump0216txt)
   - [SQLDump0217.txt](#sqldump0217txt)
   - [SQLDump0218.txt](#sqldump0218txt)
4. [Recommendations and Requests]
5. 

## Initial Message

Given the scenario where a stack dump occurred on LNPRODT at 10/22/2024 02:23:05, and considering the information from the web:

1. **DBCC CHECKDB Success**: Since DBCC CHECKDB has been confirmed successful, this suggests that the issue isn't directly related to data corruption within the database. DBCC CHECKDB checks for logical and physical integrity of the database, and its success implies that the database structure and pages are likely intact.

2. **Stack Dump Analysis**:
   - Stack dumps can occur due to various reasons including software bugs, memory issues, or hardware problems. Here are some potential causes based on general knowledge and the related posts on X:
     - **Software Bugs or Overflow**: There might be a programming error leading to a stack overflow or buffer overflow, which could have been triggered by a specific operation or data input. For instance, posts on X mention stack overflow vulnerabilities in certain software contexts like Netgear routers or even programming libraries, which might not be directly related but illustrate the concept.
     - **Memory Leaks**: Although not directly mentioned in the context of LNPRODT, memory leaks could lead to unexpected behavior or crashes. A post on X about a memory leak in a library call indicates this could be a potential issue if similar conditions exist in your environment.
     - **Hardware Issues**: Hardware problems, like RAM issues or disk I/O errors, can cause stack dumps. The lack of data corruption from DBCC CHECKDB might lean away from this, but hardware issues can sometimes manifest in software in unpredictable ways.

3. **Actions to Take**:
   - **Review Recent Changes**: Check if there have been any recent software updates, changes in the application logic, or new data inputs that might have led to this behavior.
   - **Examine the Stack Dump**: The stack trace in the dump file could provide clues about which function or module was executing when the dump occurred, potentially pointing to a specific code path or operation causing the issue.
   - **Check System Logs**: Look beyond just the database logs. The Windows Event Log or system logs might contain additional information about the system state at the time of the crash.
   - **Perform Additional Checks**:
     - **DBCC CHECKDB with TABLERESULTS**: Run DBCC CHECKDB with the TABLERESULTS option to gather more detailed information about the database state, even if it's already confirmed clean. This can sometimes catch issues not visible in a standard check.
     - **Check for Other System Resource Issues**: Ensure there are no disk space issues, memory constraints, or other system resources that might indirectly affect database operations.

4. **Conclusion**: While the database itself might be clean according to DBCC CHECKDB, the stack dump suggests an issue outside of standard data integrity problems. It could be related to how certain operations are handled in memory or how the application interacts with the database. Given the dump's nature, it would be beneficial to involve a developer or system administrator with access to the full stack trace to pinpoint the exact cause of the error. 

Remember, while the database checks out fine, the system's behavior indicates there might be an issue at the application level or with how the system is configured or operating. Further investigation into the application code and system configuration is warranted.

## System Summary
Based on the provided log summaries, here is what I can determine about the system and infrastructure being described:

1. The server experiencing the issues is named LNPRODT, which is likely a production server running SQL Server 2017 version 14.0.3465.1.

2. The server is running on Windows Server 2012 R2 and is potentially hosted on Amazon Web Services (AWS) infrastructure, as indicated by the Intel Xeon Platinum 8488C processor and BIOS version details.

3. The server is under significant memory pressure, consistently reporting 98% memory utilization, which appears to be a contributing factor to the issues.

4. The core problem manifests as an assertion failure in the `IndexRowScanner.cpp` module of SQL Server, specifically related to the `m_versionStatus.IsVisible()` function. This suggests issues with row visibility and transaction management during index operations.

5. The problem is not isolated to a single session or query, as the stack dumps show the error occurring across multiple sessions and SPIDs (Session Process IDs).

6. The involvement of SQL Server components like `sqllang.dll`, `sqlmin.dll`, `sqldk.dll`, and `sqlTsEs.dll` indicates that the issue spans across various SQL Server subsystems, including language processing, query execution, data kernel, and transactional replication.

7. There are potential contributing factors, such as:
   - Mismatches in transaction isolation level settings, potentially related to Snapshot Isolation or Read Committed Snapshot Isolation (RCSI)
   - Replication or timestamp-based operations that may be causing discrepancies in row visibility
   - Underlying data or index corruption issues not detected by standard `DBCC CHECKDB` checks
   - Hardware-related problems due to the high memory utilization

8. The customer has provided a series of SQL Server error logs and stack dumps, indicating they have been actively investigating the issue and gathering relevant information.

In summary, the system appears to be a production SQL Server 2017 instance running on Windows Server 2012 R2, potentially in an AWS environment, experiencing critical errors related to index operations and row visibility that seem to be exacerbated by high memory pressure. The customer has provided a substantial amount of information to help diagnose the root cause of the problem.

---

Your summary effectively encapsulates the key points from the log summaries:

### System and Infrastructure Overview:

- **Server**: LNPRODT, a production server running SQL Server 2017 CU20 (14.0.3465.1).
- **OS**: Windows Server 2012 R2.
- **Hosting**: Likely on AWS, inferred from the processor type (Intel Xeon Platinum 8488C) and BIOS details.

### Performance and Environmental Issues:

- **Memory**: The server is under high memory pressure, with consistent reports of 98% memory usage, which could be contributing to the errors.

### Error Details:

- **Location and Nature**: 
  - The error occurs in `IndexRowScanner.cpp` at line 1056 with an assertion failure on `m_versionStatus.IsVisible()`. This points to problems with how SQL Server determines if rows should be visible in the context of transaction isolation levels or during index operations.

- **Frequency and Scope**: 
  - The issue is recurring across different sessions (SPIDs), indicating it's not an isolated incident but rather a systemic problem within the SQL Server environment.

### SQL Server Components Involved:

- **DLLs**: The involvement of various DLLs like `sqllang.dll`, `sqlmin.dll`, `sqldk.dll`, and `sqlTsEs.dll` shows that the issue touches on multiple aspects of SQL Server's functionality, from query language processing to replication services.

### Potential Causes:

- **Transaction Isolation**: Issues might relate to how transactions are isolated, especially with features like Snapshot Isolation or RCSI.
- **Replication**: If replication is configured, there might be timing or consistency issues affecting data visibility.
- **Data Integrity**: While not confirmed, there could be subtle data or index corruption issues not caught by regular integrity checks.
- **Hardware Constraints**: The high memory usage might be pushing SQL Server to operate under suboptimal conditions.

### Customer Interaction:

- **Data Provided**: The customer has actively engaged in troubleshooting by providing extensive logs and stack dumps, which is crucial for detailed analysis.

### Next Steps for Resolution:

Given this overview:

1. **Transaction Settings**: A thorough review of transaction isolation levels and settings in use is necessary. Consider if these settings are appropriate for the workload.

2. **Memory Management**: 
   - Adjust SQL Server memory settings if possible. 
   - Monitor memory usage more closely to understand if this is a SQL Server configuration issue or if there's a broader system resource problem.

3. **Database Health**: 
   - Conduct more focused integrity checks. Use `DBCC CHECKDB` with extended options or look into index-specific integrity checks.
   - Consider offline checks if online checks aren't revealing issues.

4. **Replication Check**: If replication is involved:
   - Ensure replication processes are running correctly and in sync. 
   - Check for any latency or conflicts in replication that could introduce visibility issues.

5. **Query and Operation Review**:
   - Analyze the queries or operations that trigger this error to see if there's a pattern or commonality.

6. **SQL Server Updates**: Check if there are any service packs or cumulative updates available for SQL Server 2017 that might address known issues related to this error.

7. **External Help**: 
   - Since this appears to be a critical issue affecting production, consider engaging with Microsoft Support for deeper insight or potential hotfixes.

8. **Monitoring and Logging**: Implement or enhance monitoring to capture more details about when and how these errors occur, potentially using SQL Server Extended Events or third-party monitoring tools.

By addressing these areas, you should be able to move closer to identifying and resolving the root cause of these errors on the LNPRODT server.

## Logs Provided

### SQLDump0214.log

[contents](#contents)

Here are some additional insights and steps based on the detailed stack dump you've provided:

### Key Points from the Dump:

1. **Assertion Failure**:
   - The assertion failure at `m_versionStatus.IsVisible()` in `IndexRowScanner.cpp` suggests an issue with row visibility during an index operation. This could be related to transactions or snapshot isolation where rows should not be visible under certain conditions.

2. **Stack Trace Analysis**:
   - The stack trace shows involvement of `sqllang.dll`, `sqlmin.dll`, and `sqldk.dll`, which are core components for language processing, query execution, and data kernel operations in SQL Server.
   - The involvement of `sqlTsEs.dll` (SQL Server Transactional Replication Subscriber) might indicate that replication or timestamp/version-based operations were in play.

3. **Memory and System State**:
   - The `MemoryLoad` was at 98%, which might indicate high memory pressure, potentially affecting performance or causing instability.

4. **External Factors**:
   - The presence of various Windows API modules like `KERNELBASE`, `ADVAPI32`, `USER32` etc., suggests that the operation might have been interacting with system-level functions or user interface components, which is unusual for typical database operations.

### Recommendations for Further Investigation:

- **Analyze the Query or Operation**:
  - Attempt to reproduce the issue with the exact query or operation that was running at the time. Check for any queries involving temporal tables, snapshot isolation, or operations that manipulate transaction states extensively.

- **Check Replication Settings**:
  - If replication is configured, review the replication settings and logs. Incorrect replication configurations or conflicts could cause unexpected row visibility issues.

- **Examine Row Versioning and Isolation Levels**:
  - Look into the transaction isolation levels being used. Snapshot isolation or Read Committed Snapshot Isolation (RCSI) might be involved. Verify if there are any long-running transactions that could cause version chains to grow, potentially leading to visibility issues.

- **System Health**:
  - With high memory usage, assess if there are memory constraints on the server. Consider if there's a need for more physical memory or if memory management settings in SQL Server need adjustment.

- **Database Consistency**:
  - Although `DBCC CHECKDB` shows no corruption, consider running `DBCC CHECKTABLE` on specific tables involved in the operation where the error occurred, focusing on indexes.

- **Patch Level**:
  - Verify if there are any known issues in your SQL Server version related to index scanning or row versioning. Check if there's a patch or hotfix available.

- **Performance and Wait Stats**:
  - Review SQL Server's performance counters and wait statistics around the time of the crash to see if there were any unusual wait types or performance bottlenecks that might correlate with the error.

- **Event Viewer and Windows Logs**:
  - Look into system logs for any events around the time of the crash that might give clues about system-wide issues affecting SQL Server.

- **Consult Microsoft Support**:
   - Given the depth of the issue, particularly with the assertion in a core component, direct support from Microsoft could provide specific insights or confirm if this is a known issue in need of a fix.

This stack dump indicates a complex issue, possibly at the intersection of SQL Server's internal operations, transaction management, and potentially memory constraints. The next steps should focus on isolating the operation causing this error and examining the broader system context in which it occurs.

### SQLDump0215.log
[contents](#contents)

This SQL Server error log shows a few key issues occurring:

1. **Deadlock Situation** (around 03:01:03):
There's a deadlock between two processes trying to access the `tblPemFutureEvent` table:
- Process 2164d8c08c8 has an Update (U) lock on page 12388290 and is waiting for page 12388289
- Process 2164d037468 has an Exclusive (X) lock on page 12388289 and is waiting for page 12388290

2. **Stack Dump** (at 02:18:03):
A critical error occurred in SQL Server causing a stack dump with the error:
```
Location: IndexRowScanner.cpp:1056
Expression: m_versionStatus.IsVisible()
```

The stack dump was triggered while executing a stored procedure `pTask_GetLeaveTasks` (visible in the input buffer).

3. **Context**:
- This is happening on database `Client002_MTDB032` (dbid=70)
- The server has been running since 9/26/2024
- There were also some failed login attempts for user 'alight-com-ad\sadiscoverycomwin'

The most serious issues are:

1. The deadlock in `tblPemFutureEvent` during an UPDATE operation in the `pPem_GetFutureEvents` stored procedure
2. The critical error in the index row scanner that caused the stack dump

To resolve these:
1. For the deadlock: Review the `pPem_GetFutureEvents` procedure and consider:
   - Adding appropriate indexes
   - Reviewing transaction isolation levels
   - Potentially implementing deadlock retry logic
   
2. For the stack dump: This appears to be a SQL Server internal error related to index scanning. Consider:
   - Rebuilding indexes on affected tables
   - Running DBCC CHECKDB to verify database integrity
   - Reviewing SQL Server patch level and considering updates

### SQLDump0215.txt
[contents](#contents)

Based on the detailed SQL Server stack dump you've provided, here's a structured analysis:

### Overview:
- The dump indicates an exception occurring in SQL Server 2017 (version 14.0.3465.1) running on a system with an Intel Xeon Platinum 8488C processor and Windows Server 2012 R2.
- The high memory load (98%) could be contributing to the instability that led to this dump.

### Core Issue:
- **Location of Failure**: `IndexRowScanner.cpp:1056` with an assertion failure `m_versionStatus.IsVisible()`.
  - This suggests an issue where an index operation attempted to access or manipulate data in a way that it shouldn't have been visible or accessible under the current transaction or isolation level conditions.

### Stack Trace Insights:

1. **SQL Server Components Involved**:
   - `sqllang.dll`, `sqlmin.dll`, and `sqldk.dll` are central to this error, indicating that the problem spans across SQL language processing, query execution, and core data operations.
   - `sqlTsEs.dll` involvement points towards issues possibly related to timestamp checking or replication processes.

2. **Transaction and Concurrency**:
   - The failure in `IndexRowScanner` combined with elements like `sqlTsEs` could imply problems with row versioning, time-stamp based operations, or multi-version concurrency control issues.

### Possible Causes:

- **Transaction Isolation Level Mismatch**: If the transaction isolation level settings don't match between the session executing the query and the data it's accessing, this could lead to unexpected visibility issues.

- **Index Corruption or Integrity Issue**: Although `DBCC CHECKDB` showed no corruption, specific index corruption or metadata inconsistencies could still occur at a level not caught by general integrity checks.

- **Memory Pressure**: High memory usage might lead to SQL Server making decisions about data visibility or access that result in errors due to memory constraints or incorrect caching decisions.

- **Replication or Snapshot Isolation Failures**: If the environment uses replication or snapshot isolation, and there's a discrepancy in how these operations handle row versioning or visibility, this could trigger the assertion.

### Next Steps for Investigation:

- **Reproduce the Issue**:
  - Attempt to isolate and reproduce the specific operation or query causing this error. This might involve running the query in isolation with tracing enabled.

- **Review Transaction Settings**:
  - Check the transaction isolation level being used for the session or query. Look into whether snapshot isolation or Read Committed Snapshot Isolation (RCSI) is enabled and how it's interacting with the data.

- **Examine Index Operations**:
  - Investigate if any recent index maintenance activities or changes could have led to this state. Check index rebuilds, reorganizations, or any DDL changes that might affect visibility or integrity.

- **Memory Configuration**:
  - Review SQL Server memory settings, especially `max server memory`, to ensure they're appropriately set given the physical memory constraints and the workload.

- **Check for Known Issues**:
  - Look into Microsoft's documentation or support for known issues related to this version of SQL Server, particularly around index scanning or row versioning mechanisms.

- **Advanced Logging and Tracing**:
  - Enable extended events or additional trace flags for more detailed logging around index operations, transaction management, and memory usage.

- **Consultation with Support**:
  - Given the assertion in a core component, reaching out to Microsoft Support for more in-depth analysis might be necessary, especially if internal diagnostics don't immediately pinpoint the cause.

This error indicates a deep system issue, likely involving how SQL Server manages data consistency and access in memory or during transaction processing. The steps should aim at both diagnosing the immediate cause and understanding the broader context of system operation and configuration.

### SQLDump0216.txt

[contents](#contents)

The provided stack dump indicates another instance of a critical error in SQL Server 2017, similar to the previous one, with the following notable details:

### Key Information:

- **SQL Server Version**: 14.0.3465.1 (SQL Server 2017)
- **Error Location**: `IndexRowScanner.cpp`, line 1056
- **Assertion Failure**: `m_versionStatus.IsVisible()`, which again points to an issue with row visibility during an indexing or scanning operation.

### Analysis:

**1. System Context:**

- **Hardware**: Intel(R) Xeon(R) Platinum 8488C, with the BIOS version hinting at an Amazon Web Services environment.
- **Operating System**: Windows NT 6.2 (Windows Server 2012 R2)
- **Memory**: High memory usage with 98% MemoryLoad, indicating significant memory pressure.

**2. Error Context:**

- **SPID**: 174, different from the previous instance, suggesting this might be related to another query or session.
- **Process ID**: 5948, consistent with the previous dump, indicating this could be related to the same SQL Server instance.

**3. Stack Trace:**

- The stack involves:
  - **sqllang.dll**, **sqlmin.dll**, **sqldk.dll**, and **sqlTsEs.dll** - which are central to SQL language processing, query execution, data kernel operations, and transactional replication respectively.

- The error occurs in a similar context involving index operations, with a focus on row visibility, suggesting issues might occur during:
  - An attempt to access or scan rows that are not supposed to be visible due to transaction isolation level rules or replication mechanisms.

### Possible Causes:

- **Transaction Isolation Level Conflicts**: 
  - This error likely arises from an operation where a row's visibility does not align with what SQL Server expects based on the current transaction settings. This could involve Snapshot Isolation or Read Committed Snapshot Isolation (RCSI).

- **Memory Pressure**:
  - The high memory usage might exacerbate issues with row versioning or index operations, leading to unexpected behavior or visibility checks.

- **Replication or Timestamping Problems**:
  - The involvement of `sqlTsEs.dll` implies replication or timestamp-related issues might be at play, causing rows to appear or disappear unexpectedly during operations.

- **Data or Index Corruption**:
  - While not explicitly confirmed, there could be underlying data integrity issues not caught by `DBCC CHECKDB` that manifest during specific operations.

### Recommendations for Further Investigation:

- **Transaction Isolation Level Check**:
  - Review the transaction isolation levels in use. Ensure that the settings match the requirements of the operations being performed, particularly if you're using features like Snapshot Isolation.

- **Memory Configuration Review**:
  - Consider adjusting SQL Server's memory configuration. High memory load might lead SQL Server to make suboptimal decisions about row visibility or caching.

- **Replication Setup**:
  - If replication is configured, review for any misconfigurations or issues. Check the timing and consistency of replication transactions.

- **Index and Database Integrity Checks**:
  - Even if `DBCC CHECKDB` shows no issues, specific index checks or a more thorough data integrity analysis might reveal localized problems.

- **Extended Events Logging**:
  - Set up detailed logging using SQL Server Extended Events to capture events related to indexing, memory usage, and transaction handling around the time of the error.

- **Reproduce the Scenario**:
  - Attempt to reproduce the exact scenario leading to this error. This might require examining recent queries and operations performed under similar conditions.

- **Microsoft Support**:
  - Given it's an assertion failure within SQL Server internals, engaging Microsoft Support might provide deeper insights into what could be causing this repeated error pattern.

The recurring nature of this error (at the same location in `IndexRowScanner.cpp`) suggests a systemic issue that needs careful examination of SQL Server's operational environment, particularly focusing on transaction handling and memory management.

### SQLDump0217.txt
[contents](#contents)

The stack dump you've provided is from another occurrence of a critical error in SQL Server 2017, with details indicating:

### Key Information:

- **SQL Server Version**: 14.0.3465.1 (SQL Server 2017)
- **Error Location**: `IndexRowScanner.cpp`, line 1056
- **Assertion Failure**: `m_versionStatus.IsVisible()`, which consistently points to a problem with row visibility during index operations.

### Analysis:

**1. System Environment:**

- **Hardware**: Intel(R) Xeon(R) Platinum 8488C, suggesting this might be running on AWS given the BIOS version.
- **Operating System**: Windows NT 6.2 (Windows Server 2012 R2)
- **Memory**: The system is still under high memory pressure with 98% MemoryLoad.

**2. Error Context:**

- **SPID**: 72, indicating a different session or query encountered this issue.
- **Process ID**: 5948, consistent with previous dumps, suggesting these errors are from the same SQL Server process.

**3. Stack Trace:**

- The stack trace shows involvement of:
  - **sqllang.dll**, **sqlmin.dll**, **sqldk.dll**, **sqlTsEs.dll**, which are key components for SQL operations, indicating the error is deeply rooted in SQL Server's internal handling of data and transactions.

- This error again occurs in `IndexRowScanner.cpp` at line 1056, highlighting a consistent issue with how SQL Server manages or checks row visibility during index scanning operations.

### Potential Causes:

- **Transaction Isolation Level Issues**: 
  - The recurring problem with `m_versionStatus.IsVisible()` points towards issues with how SQL Server is handling transactions, particularly with regards to row versioning. This might relate to:
    - Incorrect or inconsistent use of Snapshot Isolation or Read Committed Snapshot Isolation (RCSI).
    - Misconfigurations or unexpected behavior in transaction management.

- **Memory Constraints**: 
  - High memory load could lead to SQL Server making suboptimal decisions about when rows should be visible, especially in memory-optimized tables or when dealing with row versioning.

- **Data Consistency or Replication Issues**:
  - If replication or timestamp-based operations are in play (as suggested by `sqlTsEs.dll`), there could be synchronization problems or unexpected behavior due to replication lag or conflicts.

- **Index Corruption or Misconfiguration**:
  - Though integrity checks might not show issues, there could be subtle problems with specific index structures or data that only become apparent during runtime operations.

### Recommendations for Investigation:

- **Review Transaction Settings**:
  - Check the transaction isolation levels set for the sessions experiencing these errors. Look into whether these levels are appropriate for the operations being performed.

- **Database and Index Health**:
  - Run specific index checks even if `DBCC CHECKDB` passes, focusing on the tables and indexes involved in the sessions at the time of the error.

- **Memory Management**:
  - Review and possibly adjust SQL Server's memory settings. Ensure that SQL Server isn't running out of memory for critical operations like maintaining transaction logs or version stores.

- **Extended Events/Tracing**:
  - Use SQL Server Extended Events to gather more detailed information about the operations leading up to this error. Focus on events related to index operations, transaction handling, and memory allocation.

- **Replication Checks**:
  - If replication is involved, ensure there are no issues with replication latency, conflicts, or configuration that could lead to data visibility problems.

- **Reproduce the Issue**:
  - Try to replicate the scenario under which this error occurs. This might involve running similar queries or operations with specific transaction settings.

- **Microsoft Support**:
  - Given the internal nature of the error (assertion failure), consulting with Microsoft Support could provide insights or patches if this is a known issue or bug in this SQL Server version.

The pattern of this error suggests a systemic problem possibly related to transaction management or index handling under high memory pressure or specific transaction isolation settings. A thorough investigation into these areas will likely yield insights into resolving or mitigating this issue.

### SQLDump0218.txt
[contents](#contents)

The provided stack dump indicates yet another occurrence of a critical error in SQL Server 2017, focusing on:

### Key Information:

- **SQL Server Version**: 14.0.3465.1 (SQL Server 2017)
- **Error Location**: `IndexRowScanner.cpp`, line 1056
- **Assertion Failure**: `m_versionStatus.IsVisible()`, continuing the pattern of problems related to row visibility during index operations.

### Analysis:

**1. System Context:**

- **Hardware**: Intel(R) Xeon(R) Platinum 8488C, indicating potentially AWS environment.
- **Operating System**: Windows NT 6.2 (Windows Server 2012 R2)
- **Memory**: High memory usage with 98% MemoryLoad, consistent with previous dumps.

**2. Error Context:**

- **SPID**: 236, indicating this error occurred in a different session.
- **Process ID**: 5948, which matches with previous dumps suggesting these issues are within the same SQL Server instance.

**3. Stack Trace:**

- The stack trace again includes:
  - **sqllang.dll**, **sqlmin.dll**, **sqldk.dll**, **sqlTsEs.dll**, highlighting the involvement of SQL Server's core functionalities in transaction processing, index management, and transaction services.

- The error at `IndexRowScanner.cpp` line 1056 suggests ongoing issues with how SQL Server manages row visibility, possibly due to:

### Potential Causes:

- **Transaction Isolation Levels**:
  - The repeated `m_versionStatus.IsVisible()` failure implies SQL Server is encountering rows that should not be considered visible under the current transaction isolation settings. This might be due to:
    - Use of Snapshot Isolation or Read Committed Snapshot Isolation (RCSI) where visibility rules are not correctly adhered to.
    - Possible issues with transaction management, like uncommitted transactions or long-running transactions affecting row visibility.

- **Memory Pressure**:
  - The high memory usage could lead to SQL Server making unexpected decisions regarding row versioning or visibility, especially in systems using memory-optimized features.

- **Data or Index Corruption**:
  - Even if basic integrity checks pass, there could be subtle corruption or inconsistencies in the data or index structures that only manifest during specific operations.

- **Replication or Timestamp Issues**:
  - The involvement of `sqlTsEs.dll` suggests replication might be playing a role, potentially leading to discrepancies in how data is perceived as visible.

### Recommendations for Further Investigation:

- **Transaction Isolation Review**:
  - Verify the transaction isolation levels for the session(s) experiencing these errors. Consider whether they are set appropriately for the operations performed.

- **Extended Events Logging**:
  - Set up SQL Server Extended Events to capture more detailed information about the operations leading to this error. Focus on transaction handling, index operations, and memory pressure events.

- **Memory Configuration Adjustment**:
  - Evaluate if SQL Server's memory allocation can be optimized to reduce pressure, possibly by adjusting the `max server memory` setting.

- **Index and Database Integrity**:
  - Conduct thorough integrity checks, focusing not just on `DBCC CHECKDB` but also on specific index operations that might reveal hidden issues.

- **Replication and Timestamp Analysis**:
  - If replication is in use, check for any anomalies or configuration issues that might affect data visibility. Look at the timing of replication processes in relation to when errors occur.

- **Query Analysis**:
  - Examine the queries or operations being performed at the time of the error. Are these operations complex joins or updates that might affect row visibility?

- **Seek Microsoft Support**:
  - Given the consistency of this error across different sessions, engaging with Microsoft support could provide deeper insights or reveal known issues with this version of SQL Server.

The recurrence of this specific error suggests there might be an underlying systemic problem with how SQL Server manages row visibility in certain scenarios, potentially exacerbated by environmental factors like high memory utilization or specific transaction settings. A detailed investigation into these areas should help in diagnosing and resolving the issue.

## Recommendations and Requests

Based on the analysis of multiple stack dumps, here's what I recommend for structuring your response:

### Immediate Recommendations

1. **Memory Management**
   - Reduce memory pressure by adjusting SQL Server's max server memory settings
   - Consider adding more RAM to the server if possible
   - Monitor memory usage patterns using Performance Monitor or similar tools

2. **Transaction Management**
   - Review and potentially adjust transaction isolation levels
   - Check for long-running transactions that might be causing version store growth
   - Consider enabling Read Committed Snapshot Isolation (RCSI) if not already enabled

3. **Index Maintenance**
   - Schedule regular index maintenance operations during off-peak hours
   - Consider rebuilding indexes on affected tables
   - Review index fragmentation levels

4. **Monitoring Setup**
   - Implement Extended Events sessions to track:
     - Transaction duration and isolation levels
     - Index operations
     - Memory pressure events
     - Row versioning operations

### Additional Information Needed

1. **Database Configuration**
   ```sql
   -- Request these queries be run:
   SELECT is_read_committed_snapshot_on, snapshot_isolation_state_desc 
   FROM sys.databases 
   WHERE database_id = DB_ID();

   SELECT * FROM sys.dm_tran_version_store_space_usage;
   ```

2. **Server Configuration**
   - Current max server memory settings
   - Physical memory configuration
   - Are there other major applications running on this server?

3. **Workload Details**
   - Peak usage times and patterns
   - Types of queries commonly running during error occurrences
   - Is replication configured? If yes, what type?

4. **Recent Changes**
   - Any recent upgrades or patches?
   - Changes to database configuration?
   - New applications or increased workload?

5. **Error Pattern**
   - Specific times when errors occur most frequently
   - Any correlation with specific database operations?
   - Are there specific tables or indexes involved more often?

### Next Steps

1. **Short Term**
   ```sql
   -- Run these diagnostic queries:
   SELECT * FROM sys.dm_exec_requests WHERE session_id > 50;
   SELECT * FROM sys.dm_os_memory_clerks ORDER BY pages_kb DESC;
   ```

2. **Medium Term**
   - Consider upgrading to a newer SQL Server version
   - Review and optimize database design
   - Implement better monitoring solutions

3. **Long Term**
   - Plan for infrastructure improvements
   - Consider implementing Always On Availability Groups for better resource management
   - Develop a comprehensive maintenance strategy

Would you like me to elaborate on any of these points or provide specific query examples for any of the recommendations?

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