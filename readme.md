Dumping power measurements every 15 seconds using crontab.

Cron job runs every 60 seconds and scripts inside dump on 0, 15, 30, 45 seconds from the start of the script. Cron can run at minimum every 1 minute.

Dumps individual node power logs to `/<script_dir>/<nodename>/<year>/<month>/YYYY-MM-DD.log`.

On new local day the previous day log is compressed with zstd. It results in about 20KB per day.

Crontab entry:

```crontab
* * * * * /nsimakov/powerlog/powerlog_cron.sh
```

Sample output from ipmitool command used in the script:

```
    Instantaneous power reading:                   296 Watts
    Minimum during sampling period:                290 Watts
    Maximum during sampling period:                305 Watts
    Average power reading over sample period:      292 Watts
    IPMI timestamp:                           Thu Oct 16 15:25:28 2025
    Sampling period:                          00000300 Seconds.
    Power reading state is:                   activated
```

Sample log file content:

```
collected_at,instant_watts,minimum_watts,maximum_watts,average_watts,ipmi_timestamp,sampling_seconds,state
2025-11-12T00:00:01-0500,301,366,779,724,"Wed Nov 12 05:00:13 2025",00000300,activated
2025-11-12T00:00:17-0500,296,366,779,724,"Wed Nov 12 05:00:28 2025",00000300,activated
2025-11-12T00:00:32-0500,296,366,779,724,"Wed Nov 12 05:00:43 2025",00000300,activated
```
