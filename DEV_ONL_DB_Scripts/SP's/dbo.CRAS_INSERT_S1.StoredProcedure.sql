/****** Object:  StoredProcedure [dbo].[CRAS_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CRAS_INSERT_S1]  

     @An_Office_IDNO                    NUMERIC(3)        ,
     @Ac_Role_ID     CHAR(10)              ,
     @Ac_NewAlphaRangeFrom_CODE    CHAR(5)              ,
     @Ac_NewAlphaRangeTo_CODE    CHAR(5)              ,
     @Ac_TypeRequest_CODE                CHAR(1)               ,
     @Ac_Worker_ID              CHAR(30)              ,
     @Ac_SignedOnWorker_ID               CHAR(30)              ,
     @An_TransactionEventSeq_NUMB                  NUMERIC(19)            
AS

/*
*     PROCEDURE NAME    : CRAS_INSERT_S1
 *     DESCRIPTION       : Insert details into Case Reassignment Request table.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/

   BEGIN

     DECLARE 
          @Li_Zero_NUMB       INT = 0,
		  @Lc_No_TEXT       CHAR(1) ='N',
		  @Ld_Low_DATE          DATE = '01/01/0001',
		  @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Current_DATE DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();


     INSERT CRAS_Y1(                
Office_IDNO,                    
Role_ID,                        
Worker_ID,                      
Request_DATE,                   
NewAlphaRangeFrom_CODE ,        
NewAlphaRangeTo_CODE ,          
Status_CODE,                    
TypeRequest_CODE,               
WorkerRequest_ID,				
Processed_DATE,					
WorkerUpdate_ID	,				
TransactionEventSeq_NUMB,		
Update_DTTM						
      )                        
 VALUES (        
 		@An_Office_IDNO,
 	    @AC_Role_ID,            
         @Ac_SignedOnWorker_ID,      
         @Ld_Current_DATE,
         @Ac_NewAlphaRangeFrom_CODE,
         @Ac_NewAlphaRangeTo_CODE,
         @Lc_No_TEXT,
         @Ac_TypeRequest_CODE,
		@Ac_Worker_ID,
		@Ld_Low_DATE,
		@Ac_SignedOnWorker_ID,
		@An_TransactionEventSeq_NUMB,
		@Ld_Current_DATE
          );

                  
END


GO
