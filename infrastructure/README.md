# Server side code

### DataStructures



**Client First Request**

|FieldName|Type|Description|
|---|---|---|
|type|Int|MSG_NEW_GAME_REQ|
|player_name|String|Limited to X characters|


**Server Response**

|FieldName|Type|Description|
|---|---|---|
|type|Int|MSG_CONNECTION_INFO|
|user_id|String|Unique ID for this game|
|game_id|String||
|access_key_id|String|AWS Credentials|
|secret_access_key|String|AWS Credentials|
|session_token|String|AWS Credentials|
|sns_topic_arn|String|AWS multiplex SNS topic|
|sqs_url|String|AWS Queue to consume from|
|game_seed|Int|random number generator seed|

----
**Client Ready State**

|FieldName|Type|Description|
|---|---|---|
|type|Int|MSG_READY_STATE|
|user_id|String|Unique ID for this game|
|game_id|String||
|is_ready|Bool||

**Server Response**

|FieldName|Type|Description|
|---|---|---|
|type|Int|MSG_READY_STATE_RES|
|game_id|String||
|player_names|Array||
|game_start|Bool||
