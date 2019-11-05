-- Do search and replace of <database> with your actual database name, without the angle brackets
use <database>

-- continuous queries

CREATE RETENTION POLICY aggregated    ON <database> DURATION 400d REPLICATION 1
-- Router
DROP   CONTINUOUS QUERY host_router   ON <database>
DROP   CONTINUOUS QUERY total_router  ON <database>
DROP   CONTINUOUS QUERY tenant_router ON <database>
CREATE CONTINUOUS QUERY host_router   ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeQueuedInteractions) AS activeQueuedInteractions, sum(loggedAgents) AS loggedAgents INTO aggregated.host_router   FROM router GROUP BY hostname, time(10s) END
CREATE CONTINUOUS QUERY total_router  ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeQueuedInteractions) AS activeQueuedInteractions, sum(loggedAgents) AS loggedAgents INTO aggregated.total_router  FROM router GROUP BY time(10s) END
CREATE CONTINUOUS QUERY tenant_router ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeQueuedInteractions) AS activeQueuedInteractions, sum(loggedAgents) AS loggedAgents INTO aggregated.tenant_router FROM router GROUP BY tenant,   time(10s) END

-- Dialer
DROP   CONTINUOUS QUERY host_dialer   ON <database>
DROP   CONTINUOUS QUERY total_dialer  ON <database>
CREATE CONTINUOUS QUERY host_dialer   ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeCalls) AS activeCalls INTO aggregated.host_dialer FROM dialer GROUP BY hostname, time(10s) END
CREATE CONTINUOUS QUERY total_dialer  ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeCalls) AS activeCalls INTO aggregated.total_dialer FROM dialer GROUP BY time(10s) END

-- Scenarios
DROP   CONTINUOUS QUERY host_scenario   ON <database>
DROP   CONTINUOUS QUERY tenant_scenario ON <database>
DROP   CONTINUOUS QUERY total_scenario  ON <database>
CREATE CONTINUOUS QUERY host_scenario   ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeVoiceInteractions) AS activeVoiceInteractions, sum(activeChatInteractions) AS activeChatInteractions INTO aggregated.host_scenario FROM scenarioengine GROUP BY time(10s), hostname END
CREATE CONTINUOUS QUERY tenant_scenario ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeVoiceInteractions) AS activeVoiceInteractions, sum(activeChatInteractions) AS activeChatInteractions INTO aggregated.tenant_scenario FROM scenarioengine GROUP BY time(10s), tenant END
CREATE CONTINUOUS QUERY total_scenario  ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeVoiceInteractions) AS activeVoiceInteractions, sum(activeChatInteractions) AS activeChatInteractions INTO aggregated.total_scenario FROM scenarioengine GROUP BY time(10s) END

-- SIP Calls
DROP   CONTINUOUS QUERY total_sip_calls ON <database>
CREATE CONTINUOUS QUERY total_sip_calls ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(activeCalls) AS activeCalls INTO aggregated.total_sip_calls FROM "sipprocessor.trunk" GROUP BY time(10s) END

-- Agents
DROP   CONTINUOUS QUERY agents_totals   ON <database>
DROP   CONTINUOUS QUERY host_agents     ON <database>
DROP   CONTINUOUS QUERY total_agents    ON <database>
DROP   CONTINUOUS QUERY tenant_agents   ON <database>
CREATE CONTINUOUS QUERY total_agents    ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(loggedAgents) AS loggedAgents INTO aggregated.total_agents  FROM agentserver group by time(10s) END
CREATE CONTINUOUS QUERY host_agents     ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(loggedAgents) AS loggedAgents INTO aggregated.host_agents   FROM agentserver group by time(10s), hostname END
CREATE CONTINUOUS QUERY tenant_agents   ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(loggedAgents) AS loggedAgents, sum(totalConnectionLossLogouts) AS totalConnectionLossLogouts INTO aggregated.tenant_agents FROM agentserver group by time(10s), tenant END

-- Emails
DROP   CONTINUOUS QUERY host_emails     ON <database>
DROP   CONTINUOUS QUERY tenant_emails   ON <database>
DROP   CONTINUOUS QUERY total_emails    ON <database>
CREATE CONTINUOUS QUERY host_emails     ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(totalEmailsReceived) AS emailsReceived, sum(totalEmailsSent) AS emailsSent, sum(totalConnectErrors) AS connectErrors, sum(totalEmailsSentError) AS emailsSentErrors INTO aggregated.host_emails   FROM emailserver group by time(10s), hostname END
CREATE CONTINUOUS QUERY tenant_emails   ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(totalEmailsReceived) AS emailsReceived, sum(totalEmailsSent) AS emailsSent, sum(totalConnectErrors) AS connectErrors, sum(totalEmailsSentError) AS emailsSentErrors INTO aggregated.tenant_emails FROM emailserver group by time(10s), tenant END
CREATE CONTINUOUS QUERY total_emails    ON <database> RESAMPLE EVERY 10s FOR 20s BEGIN select sum(totalEmailsReceived) AS emailsReceived, sum(totalEmailsSent) AS emailsSent, sum(totalConnectErrors) AS connectErrors, sum(totalEmailsSentError) AS emailsSentErrors INTO aggregated.total_emails  FROM emailserver group by time(10s) END

