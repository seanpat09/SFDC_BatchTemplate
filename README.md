SFDC_BatchTemplate
==================

I've written a lot of batches and they generally the same structure:

1) Create a query locator
2) Execute the batch
3) Do error handling in finish (which is usually just emailing the job creator the errors)

Now you can instantiate a BatchHandler with a BatchHelper that holds all of the batch logic!
Only one batch framework that's flow tested to call all of your methods and all you need to do is implement the helper.

You either implement getQuery, execute and finish yourself:

	public with sharing class MyBatchHelper implements IBatchHelper
	{
		String getQuery()
		{
			//Your query string
			return 'SELECT Id FROM User';
		}
	    void execute( Database.BatchableContext bc, List<sObject> scope )
    	{
    		//your logic
 	    }
    	void finish( Database.BatchableContext bc, Id jobId )
    	{
	    	//your finish logic
    	}
    }

Or extend StandardBatchFinish:

	public with sharing class MyExtendedBatchHelper extends StandardBatchFinish implement IBatchHelper
	{
		String getQuery()
		{
			//Your query string
			return 'SELECT Id FROM User';
		}
    	void execute( Database.BatchableContext bc, List<sObject> scope )
    	{
    		//your logic
    	}
    }
    
To make your batch schedulable, all you need to do is extend the BatchScheduler class
NOTE: If you want to schedule your class through the Salesforce UI, your extension also needs to implement Schedulable even though the BatchScheduler base class also implements it


	global class DemoBatchScheduler extends BatchScheduler implements Schedulable
	{	
    	global DemoBatchScheduler()
	    {
    	    super(10, 'batch title');
    	}
    	global void execute(SchedulableContext SC)
	    {
    	    schedule( new MyExtendedBatchHelper('batch title') );
    	}
	}
	

BatchScheduler will handle scheduling your batch, check if 5 batches are currently running, and reschedule your batch if necessary. The integer you pass into the super constructor is the number of minutes to wait before running the batch again and the string is the title

This tool does no DMLs and relies on no data, so you can easily drop it into your org!