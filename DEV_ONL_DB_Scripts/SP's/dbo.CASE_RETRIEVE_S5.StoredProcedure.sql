/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S5] (
 @An_Case_IDNO 						NUMERIC(6, 0),
 @Ac_StatusCase_CODE				CHAR(1)			OUTPUT,
 @Ac_TypeCase_CODE					CHAR(1)			OUTPUT,
 @Ac_RespondInit_CODE				CHAR(1)			OUTPUT,
 @An_County_IDNO					NUMERIC(3,0)	OUTPUT,
 @An_Office_IDNO					NUMERIC(3,0)	OUTPUT,
 @Ac_Restricted_INDC				CHAR(1)			OUTPUT,
 @An_TransactionEventSeq_NUMB		NUMERIC(19,0)	OUTPUT,
 @Ac_File_ID						CHAR(10)		OUTPUT,
 @Ac_Worker_ID                      CHAR(30)        OUTPUT,
 @Ac_CaseCategory_CODE				CHAR(2)			OUTPUT,
 @Ad_Opened_DATE					DATE			OUTPUT,
 @As_DescriptionComments_TEXT		VARCHAR(200)	OUTPUT,
 @Ac_NonCoop_CODE					CHAR(1)			OUTPUT,
 @Ac_GoodCause_CODE					CHAR(1)			OUTPUT,
 @Ac_ApplicationFee_CODE			CHAR(1)			OUTPUT
)
AS
 /*                                                                  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S5                        
  *     DESCRIPTION       :  If a Case is not an Intergovermental Case then while changing the Case to Intergovermental , move the CASE Record to Histroy table.
  *     DEVELOPED BY      : IMP Team                               
  *     DEVELOPED ON      : 25-AUG-2011                          
  *     MODIFIED BY       :                                          
  *     MODIFIED ON       :                                          
  *     VERSION NO        : 1                                        
 */
 BEGIN
  
  SELECT @Ac_StatusCase_CODE	        = NULL,			
		 @Ac_TypeCase_CODE	            = NULL,				
		 @Ac_RespondInit_CODE	        = NULL,			
		 @An_County_IDNO 	            = NULL,				
		 @An_Office_IDNO	            = NULL,				
		 @Ac_Restricted_INDC	        = NULL,			
		 @An_TransactionEventSeq_NUMB	= NULL,		
		 @Ac_File_ID                    = NULL,
		 @Ac_CaseCategory_CODE	        = NULL,		
		 @Ad_Opened_DATE                = NULL,						
		 @As_DescriptionComments_TEXT	= NULL,		
		 @Ac_NonCoop_CODE	            = NULL,					
		 @Ac_GoodCause_CODE	            = NULL,					
		 @Ac_ApplicationFee_CODE	    = NULL;						

  SELECT @Ac_StatusCase_CODE          = c.StatusCase_CODE,
         @Ac_TypeCase_CODE            = c.TypeCase_CODE,
         @Ac_RespondInit_CODE         = c.RespondInit_CODE,
         @An_County_IDNO              = c.County_IDNO,
         @An_Office_IDNO              = c.Office_IDNO,
         @Ac_Restricted_INDC          = c.Restricted_INDC,
         @An_TransactionEventSeq_NUMB = c.TransactionEventSeq_NUMB,
         @Ac_File_ID                  = c.File_ID,
         @Ac_Worker_ID                = c.Worker_ID,
         @Ac_CaseCategory_CODE	      = c.CaseCategory_CODE, 		
		 @Ad_Opened_DATE              = c.Opened_DATE,			
		 @As_DescriptionComments_TEXT = c.DescriptionComments_TEXT,
		 @Ac_NonCoop_CODE	          = c.NonCoop_CODE,			
		 @Ac_GoodCause_CODE	          = c.GoodCause_CODE,			
		 @Ac_ApplicationFee_CODE      = c.ApplicationFee_CODE		
    FROM CASE_Y1 C
   WHERE
	C.Case_IDNO = @An_Case_IDNO;
 END--END OF CASE_RETRIEVE_S5


GO
