/** Date : 17/6/2019
 *  Purpose : This is Scheduler class of BatchSyncApplicantCompleteDetails to schedule batch class.
**/

global class ScheduleBatchApplicantCompleteDetails implements Schedulable {
    global void execute(SchedulableContext schedulableConObj){
        BatchSyncApplicantCompleteDetails syncApplicantDetailBatchObj = new BatchSyncApplicantCompleteDetails();
        database.executeBatch(syncApplicantDetailBatchObj,1);
    }
}