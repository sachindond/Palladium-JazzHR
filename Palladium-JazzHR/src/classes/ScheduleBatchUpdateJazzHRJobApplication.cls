/** Date : 04/06/2019 
*  Schedule class for BatchUpdateJazzHRJobApplication
**/
global class ScheduleBatchUpdateJazzHRJobApplication implements Schedulable{
    global void execute(SchedulableContext schedulableConObj){
        BatchUpdateJazzHRJobApplication bcObject = new BatchUpdateJazzHRJobApplication();
        database.executeBatch(bcObject,20);
    }
}