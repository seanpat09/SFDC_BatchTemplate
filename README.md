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
    
To make your batch schedulable, all you need to do is extend the BatchScheduler class:

	global class DemoBatchScheduler extends BatchScheduler
	{	
    	global DemoBatchScheduler()
	    {
    	    super(10);
    	}
    	global void execute(SchedulableContext SC)
	    {
    	    schedule( new DemoBatchHelper('Case Hold Clear Job') );
    	}
	}
	
BatchScheduler will handle scheduling you batch, check if 5 batches are currently running, and reschedule your batch if necessary.
The integer you pass into the super constructor is the number of minutes to wait before running the batch again.

This tool does no DMLs and relies on no data, so you can easily drop it into your org!