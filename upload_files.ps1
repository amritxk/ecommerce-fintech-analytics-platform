# ============================================================================
# Upload Files to Snowflake Stages using SnowSQL
# This script uploads all synthetic data files to Snowflake in a single session
# ============================================================================

# Configuration
$SNOWFLAKE_ACCOUNT = "STBPLNO-WK22236"
$SNOWFLAKE_USER = "AMRITKESHRI12345"
$SNOWFLAKE_WAREHOUSE = "TRANSFORM_WH"
$SNOWFLAKE_DB = "EXTERNAL_STAGES_DB"
$SNOWFLAKE_SCHEMA = "STAGES"
$DATA_DIR = "C:\users\amritkeshri\documents\ecommerce_fintech_project\synthetic_data"

# Create SQL file with all PUT commands
$SQL_FILE = "upload_commands.sql"

$sql_commands = @"
-- Upload to ECOMMERCE_STAGE
PUT file://$DATA_DIR/customers.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/products.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/promotions.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/orders.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/order_items.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/reviews.csv @ECOMMERCE_STAGE AUTO_COMPRESS=FALSE;

-- Upload to FINTECH_STAGE
PUT file://$DATA_DIR/transactions.csv @FINTECH_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/chargebacks.csv @FINTECH_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/returns.csv @FINTECH_STAGE AUTO_COMPRESS=FALSE;
PUT file://$DATA_DIR/complaints.csv @FINTECH_STAGE AUTO_COMPRESS=FALSE;

-- Upload to EVENTS_STAGE
PUT file://$DATA_DIR/events.csv @EVENTS_STAGE AUTO_COMPRESS=FALSE;

-- List uploaded files to verify
LIST @ECOMMERCE_STAGE;
LIST @FINTECH_STAGE;
LIST @EVENTS_STAGE;
"@

# Write SQL commands to file
$sql_commands | Out-File -FilePath $SQL_FILE -Encoding UTF8

Write-Host "Starting file upload to Snowflake..." -ForegroundColor Green
Write-Host "Data directory: $DATA_DIR" -ForegroundColor Cyan
Write-Host ""
Write-Host "You will be prompted for your Snowflake password once." -ForegroundColor Yellow
Write-Host ""

# Run SnowSQL with piped input
# This sends all commands in a single session
Get-Content $SQL_FILE | snowsql -a $SNOWFLAKE_ACCOUNT `
                               -u $SNOWFLAKE_USER `
                               -d $SNOWFLAKE_DB `
                               -s $SNOWFLAKE_SCHEMA `
                               -w $SNOWFLAKE_WAREHOUSE

Write-Host ""
Write-Host "Upload complete!" -ForegroundColor Green
Write-Host "Files have been uploaded to Snowflake stages." -ForegroundColor Green

# Clean up SQL file
Remove-Item -Path $SQL_FILE -Force

Write-Host ""
Write-Host "Next step: Run 02_load_data.sql in Snowflake to copy data into tables." -ForegroundColor Cyan
