/****** Object:  StoredProcedure [dbo].[ICAS_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_UPDATE_S4]  
	(
     @An_Case_IDNO		 				NUMERIC(6,0), 
     @Ac_IVDOutOfStateFips_CODE		 	CHAR(2),
     @Ac_IVDOutOfStateCase_ID           CHAR(15),
     @Ac_IVDOutOfStateTypeCase_CODE     CHAR(1),
     @An_TransactionEventSeq_NUMB       NUMERIC(19,0),
     @An_RespondentMci_IDNO             NUMERIC(10, 0),
     @Ac_SignedonWorker_ID              CHAR(30)   
    ) 
AS                                                         

/*
 *     PROCEDURE NAME    : ICAS_UPDATE_S4
 *     DESCRIPTION       : Update the Other State Case ID and Case Type.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 04-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN
     DECLARE
         @Lc_Space_TEXT            CHAR(1) =' ',
		 @Lc_StatusOpen_CODE	CHAR(1) = 'O' ,
         @Ld_High_DATE             DATE = '12/31/9999',
         @Ld_SystemDatetime_DTTM   DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
         
         UPDATE ICAS_Y1
          SET EndValidity_DATE = @Ld_SystemDatetime_DTTM  
     OUTPUT    
           @An_Case_IDNO AS Case_IDNO,
           @Ac_IVDOutOfStateFips_CODE AS IVDOutOfStateFips_CODE,
           Deleted.IVDOutOfStateFile_ID,
           Deleted.Reason_CODE,
           @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
           @Ac_IVDOutOfStateCase_ID AS IVDOutOfStateCase_ID,
           Deleted.IVDOutOfStateOfficeFips_CODE,
           Deleted.IVDOutOfStateCountyFips_CODE,
           Deleted.Status_CODE,
           Deleted.Effective_DATE,
           Deleted.End_DATE,
           Deleted.RespondInit_CODE,
           Deleted.ControlByCrtOrder_INDC,
           Deleted.ContOrder_DATE,
           Deleted.ContOrder_ID,
           Deleted.Petitioner_NAME,
           Deleted.ContactFirst_NAME,
           Deleted.Respondent_NAME,
           Deleted.ContactLast_NAME,
           Deleted.ContactMiddle_NAME,
           Deleted.PhoneContact_NUMB,
           Deleted.Referral_DATE,
           Deleted.Contact_EML,
           Deleted.FaxContact_NUMB,
           Deleted.File_ID,
           Deleted.County_IDNO,
           @Ac_IVDOutOfStateTypeCase_CODE AS IVDOutOfStateTypeCase_CODE,
           Deleted.Create_DATE,
           Deleted.Worker_ID,
           @Ld_SystemDatetime_DTTM AS Update_DTTM,
           @Ac_SignedonWorker_ID AS WorkerUpdate_ID,
           @Ld_High_DATE AS EndValidity_DATE,
           @Ld_SystemDatetime_DTTM AS BeginValidity_DATE,
           Deleted.RespondentMci_IDNO,
           Deleted.PetitionerMci_IDNO,
           Deleted.DescriptionComments_TEXT
      INTO ICAS_Y1
           (
              Case_IDNO,                   
              IVDOutOfStateFips_CODE,      
              IVDOutOfStateFile_ID,        
              Reason_CODE,                 
              TransactionEventSeq_NUMB,    
              IVDOutOfStateCase_ID,        
              IVDOutOfStateOfficeFips_CODE,
              IVDOutOfStateCountyFips_CODE,
              Status_CODE,                 
              Effective_DATE,              
              End_DATE,                    
              RespondInit_CODE,            
              ControlByCrtOrder_INDC,      
              ContOrder_DATE,              
              ContOrder_ID,                
              Petitioner_NAME,             
              ContactFirst_NAME,           
              Respondent_NAME,             
              ContactLast_NAME,            
              ContactMiddle_NAME,          
              PhoneContact_NUMB,           
              Referral_DATE,               
              Contact_EML,                 
              FaxContact_NUMB,             
              File_ID,                     
              County_IDNO,                 
              IVDOutOfStateTypeCase_CODE,  
              Create_DATE,                 
              Worker_ID,                   
              Update_DTTM,                 
              WorkerUpdate_ID,             
              EndValidity_DATE,            
              BeginValidity_DATE,          
              RespondentMci_IDNO,          
              PetitionerMci_IDNO,          
              DescriptionComments_TEXT    
           
           )
      WHERE 
		 Case_IDNO = @An_Case_IDNO AND 
		 IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE AND
	     Status_CODE		= @Lc_StatusOpen_CODE AND
		 EndValidity_DATE =@Ld_High_DATE AND
		 TransactionEventSeq_NUMB <> @An_TransactionEventSeq_NUMB AND 
		 RespondentMci_IDNO=@An_RespondentMci_IDNO AND
		 ((((RTRIM(LTRIM(IVDOutOfStateCase_ID)) = '') OR IVDOutOfStateCase_ID <> ISNULL(@Ac_IVDOutOfStateCase_ID,''))) OR
		 (((RTRIM(LTRIM(IVDOutOfStateTypeCase_CODE)) = '') OR IVDOutOfStateTypeCase_CODE <> ISNULL(@Ac_IVDOutOfStateTypeCase_CODE,''))))
          
END; -- END OF ICAS_UPDATE_S4

GO
