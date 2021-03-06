/****** Object:  StoredProcedure [dbo].[URCT_UPDATE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[URCT_UPDATE_S2]  (

     @Ad_Batch_DATE		                DATE,
     @Ac_SourceBatch_CODE		        CHAR(3),
     @An_Batch_NUMB                     NUMERIC(4,0),
     @An_SeqReceipt_NUMB		        NUMERIC(6,0),     
     @Ac_SourceReceipt_CODE		        CHAR(2),
     @As_Payor_NAME                     VARCHAR(71),
     @Ac_PayorLine1_ADDR		        CHAR(25),
     @Ac_PayorLine2_ADDR		        CHAR(25),
     @Ac_PayorCity_ADDR		            CHAR(20),
     @Ac_PayorState_ADDR		        CHAR(2),
     @Ac_PayorZip_ADDR		            CHAR(15),
     @Ac_PayorCountry_ADDR		        CHAR(30),
     @As_Bank_NAME		                VARCHAR(50),
     @Ac_Bank1_ADDR		                CHAR(25),
     @Ac_Bank2_ADDR		                CHAR(25),
     @Ac_BankCity_ADDR		            CHAR(20),
     @Ac_BankState_ADDR		            CHAR(2),
     @Ac_BankZip_ADDR		            CHAR(15),
     @Ac_BankCountry_ADDR		        CHAR(30),
     @An_Bank_IDNO		                NUMERIC(10,0),
     @An_BankAcct_NUMB		            NUMERIC(17,0),
     @As_Remarks_TEXT		            VARCHAR(328),
     @An_CaseIdent_IDNO		            NUMERIC(6,0),
     @An_IdentifiedPayorMci_IDNO		NUMERIC(10,0),
     @Ad_Identified_DATE                DATE,
     @An_OtherParty_IDNO		        NUMERIC(9,0),
     @Ac_IdentificationStatus_CODE      CHAR(1),
     @An_Employer_IDNO		            NUMERIC(9,0),
     @An_IvdAgency_IDNO		            NUMERIC(7,0),
     @An_UnidentifiedMemberMci_IDNO	    NUMERIC(10,0),
     @An_UnidentifiedSsn_NUMB		    NUMERIC(9,0),
     @An_EventGlobalBeginSeq_NUMB		NUMERIC(19,0),
     @An_EventGlobalEndSeq_NUMB		    NUMERIC(19,0),
     @Ad_StatusEscheat_DATE		        DATE,
     @Ac_StatusEscheat_CODE		        CHAR(2)  
     )          
AS

/*
 *     PROCEDURE NAME    : URCT_UPDATE_S2
 *     DESCRIPTION       : Updates the event global end seq and end validity date for URCT 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 24-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
   BEGIN


      DECLARE
         @Lc_StatusReceiptUnidentified_CODE    CHAR(1) = 'U', 
         @Ld_High_DATE                         DATE = '12/31/9999',
         @Ld_Current_DATE                      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Ln_RowsAffected_NUMB                 NUMERIC(10),
         @Li_Zero_NUMB                         SMALLINT = 0;
         
     UPDATE URCT_Y1
     SET      
       EndValidity_DATE = @Ld_Current_DATE,
       EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB
     OUTPUT 
        Deleted.Batch_DATE, 
        Deleted.SourceBatch_CODE, 
        Deleted.Batch_NUMB, 
        Deleted. SeqReceipt_NUMB, 
        @An_EventGlobalEndSeq_NUMB AS    EventGlobalBeginSeq_NUMB, 
        @Ac_SourceReceipt_CODE, 
        @As_Payor_NAME, 
        @Ac_PayorLine1_ADDR, 
        @Ac_PayorLine2_ADDR, 
        @Ac_PayorCity_ADDR, 
        @Ac_PayorState_ADDR, 
        @Ac_PayorZip_ADDR, 
        @Ac_PayorCountry_ADDR, 
        @As_Bank_NAME, 
        @Ac_Bank1_ADDR, 
        @Ac_Bank2_ADDR, 
        @Ac_BankCity_ADDR, 
        @Ac_BankState_ADDR, 
        @Ac_BankZip_ADDR, 
        @Ac_BankCountry_ADDR, 
        @An_Bank_IDNO, 
        @An_BankAcct_NUMB, 
        @As_Remarks_TEXT, 
        @An_CaseIdent_IDNO, 
        @An_IdentifiedPayorMci_IDNO, 
        @Ad_Identified_DATE,
        @An_OtherParty_IDNO,
        @Ac_IdentificationStatus_CODE , 
        @An_Employer_IDNO, 
        @An_IvdAgency_IDNO, 
        @An_UnidentifiedMemberMci_IDNO, 
        @An_UnidentifiedSsn_NUMB, 
        @Li_Zero_NUMB AS EventGlobalEndSeq_NUMB, 
        @Ld_Current_DATE AS BeginValidity_DATE, 
        @Ld_High_DATE AS EndValidity_DATE, 
        @Ad_StatusEscheat_DATE, 
        @Ac_StatusEscheat_CODE
       INTO
         URCT_Y1
     WHERE Batch_DATE = @Ad_Batch_DATE 
       AND  Batch_NUMB = @An_Batch_NUMB 
       AND  SeqReceipt_NUMB = @An_SeqReceipt_NUMB 
       AND  SourceBatch_CODE = @Ac_SourceBatch_CODE 
       AND  IdentificationStatus_CODE =@Lc_StatusReceiptUnidentified_CODE 
       AND  EndValidity_DATE = @Ld_High_DATE
       AND  EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB
     
   SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;   
       
     
END; -- END OF URCT_UPDATE_S2   

GO
