/**
 * Developer    : Vinit/Sachin
 * Date         : 29 Jan 2018
 * Purpose      : Schedule class for All Batches for JazzHR Sync
 * Batch Chining is used to call User --> Job --> Applicant Data For Yesterday. To run these batches for specific date, update custom settings for JazzHR.
 
**/
global class ScheduleJazzHRBatches implements Schedulable{
    global void execute(SchedulableContext schedulableConObj){
        BatchSyncUsersFromJazzHR userBatchObj = new BatchSyncUsersFromJazzHR();
        database.executeBatch(userBatchObj);
    }
}