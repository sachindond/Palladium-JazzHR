/** Date : 18/6/2019
 *  Purpose : Scheduler batch class for BatchDeleteJobApplications
**/
global class ScheduleBatchDeleteJobApplications implements Schedulable  {
    global void execute(SchedulableContext ctx) {
        BatchDeleteJobApplications batchObj = new BatchDeleteJobApplications();
        database.executeBatch(batchObj,200);
    }
}