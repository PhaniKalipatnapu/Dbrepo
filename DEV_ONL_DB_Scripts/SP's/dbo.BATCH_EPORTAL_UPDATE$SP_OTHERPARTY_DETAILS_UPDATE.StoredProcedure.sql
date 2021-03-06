/****** Object:  StoredProcedure [dbo].[BATCH_EPORTAL_UPDATE$SP_OTHERPARTY_DETAILS_UPDATE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_EPORTAL_UPDATE$SP_OTHERPARTY_DETAILS_UPDATE
Programmer Name		: IMP Team.
Description			: Updates process indicator to Y for a given employer.
Frequency			: 
Developed On		: 08/14/1012
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[BATCH_EPORTAL_UPDATE$SP_OTHERPARTY_DETAILS_UPDATE] (
 @An_OtherParty_IDNO              NUMERIC(9,0),
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @Ac_ReceivePaperForms_INDC       CHAR(1),
 @Ac_WorkerUpdate_ID              CHAR(30),
 @Ad_Process_DATE                 DATE,
 @An_Error_NUMB					  NUMERIC OUTPUT,
 @An_ErrorLine_NUMB				  NUMERIC OUTPUT,
 @Ac_Msg_CODE					  CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT		  VARCHAR(4000) OUTPUT,
 @As_Sql_TEXT					  VARCHAR(4000) OUTPUT,
 @As_Sqldata_TEXT				  VARCHAR(4000) OUTPUT
 )
AS
BEGIN
  SET NOCOUNT ON;
 
 BEGIN
  DECLARE 
          @Lc_SuccessStatus_CODE		CHAR(1) = 'S',           
          @Lc_StatusFailed_CODE		    CHAR(1) = 'F',
          @Lc_ProcessYes_INDC           CHAR(1) = 'Y',
          @Ls_ErrorMessage_TEXT         CHAR (30)= 'UPDATE MEPDT_Y1 TABLE FAILED',
          @Lc_Msg_CODE                  CHAR(5),
		  @Ln_Error_NUMB				NUMERIC,
		  @Ln_Rowcount_QNTY			    NUMERIC,
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Ls_Sql_TEXT					VARCHAR(200) = '',
          @Ls_Sqldata_TEXT				VARCHAR(2000) = '',
          @Ls_DescriptionError_TEXT	    VARCHAR(4000) = '',
          @Ld_Systemdate_DTTM           DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE                 DATE = '12/31/9999';
          
          
BEGIN
   TRY
       SET @Ls_Sql_TEXT = 'UPDATE MEPDT_Y1 TABLE';
       SET @Ls_Sqldata_TEXT = 'EndValidity_DATE = ' + CAST(@Ad_Process_DATE AS VARCHAR) +  ', BeginValidty_DATE = ' + CAST(@Ad_Process_DATE AS VARCHAR)+ ', EndValidty_DATE = ' + CAST(@Ld_High_DATE AS VARCHAR)+  ', Update_DTTM = ' + CAST(@Ld_Systemdate_DTTM AS VARCHAR)+', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR), '')+', WorkerUpdate_ID = ' + ISNULL(@Ac_WorkerUpdate_ID, '')+ ', ReceivePaperForms_INDC = ' + ISNULL(@Ac_ReceivePaperForms_INDC, '') ;
  
  UPDATE OTHP_Y1
         SET EndValidity_DATE = @Ad_Process_DATE
      OUTPUT Deleted.OtherParty_IDNO,
             Deleted.TypeOthp_CODE,
             Deleted.OtherParty_NAME,
             Deleted.Aka_NAME,
             Deleted.Attn_ADDR,
             Deleted.Line1_ADDR,
             Deleted.Line2_ADDR,
             Deleted.City_ADDR,
             Deleted.Zip_ADDR,
             Deleted.State_ADDR,
             Deleted.Fips_CODE,
             Deleted.Country_ADDR,
             Deleted.DescriptionContactOther_TEXT,
             Deleted.Phone_NUMB,
             Deleted.Fax_NUMB,
             Deleted.ReferenceOthp_IDNO,
             Deleted.NewOtherParty_IDNO,
             Deleted.Fein_IDNO,
             Deleted.Contact_EML,
             Deleted.ParentFein_IDNO,
             Deleted.InsuranceProvided_INDC,
             Deleted.Sein_IDNO,
             Deleted.County_IDNO,
             Deleted.DchCarrier_IDNO,
             Deleted.Nsf_INDC,
             Deleted.Verified_INDC,
             Deleted.Note_INDC,
             Deleted.Eiwn_INDC,
             Deleted.Enmsn_INDC,
             Deleted.NmsnGen_INDC,
             Deleted.NmsnInst_INDC,
             Deleted.Tribal_CODE,
             Deleted.Tribal_INDC,
             @Ad_Process_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             @Ac_WorkerUpdate_ID AS WorkerUpdate_ID,
             @Ld_Systemdate_DTTM AS Update_DTTM,
             @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
             Deleted.SendShort_INDC,
             Deleted.PpaEiwn_INDC,
             Deleted.DescriptionNotes_TEXT,
             Deleted.Normalization_CODE,
             Deleted.EportalSubscription_INDC,
             Deleted.BarAtty_NUMB,
             @Ac_ReceivePaperForms_INDC AS ReceivePaperForms_INDC
        INTO OTHP_Y1
       WHERE OtherParty_IDNO = @An_OtherParty_IDNO
         AND TransactionEventSeq_NUMB = (SELECT MAX(o.TransactionEventSeq_NUMB)
                                           FROM OTHP_Y1 o
                                          WHERE o.OtherParty_IDNO = @An_OtherParty_IDNO
                                            AND o.EndValidity_DATE = @Ld_High_DATE)
         AND EndValidity_DATE = @Ld_High_DATE;
 SET @Ln_RowCount_QNTY = @@ROWCOUNT;
	  
      IF @Ln_RowCount_QNTY = 1
       BEGIN
        SET @Lc_Msg_CODE = @Lc_SuccessStatus_CODE;
       END;
      ELSE
       BEGIN
        SET @Lc_Msg_CODE = @Lc_StatusFailed_CODE;
        SET @Ls_DescriptionError_TEXT = @Ls_ErrorMessage_TEXT ;

        RAISERROR (50001,16,1);
       END
     
      SET @Ac_Msg_CODE = @Lc_SuccessStatus_CODE;    
     
     END TRY
     
    BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
    --Check for Exception information to log the description text based on the error
    SET @Ln_Error_NUMB = ERROR_NUMBER();  
	SET @Ln_ErrorLine_NUMB = ERROR_LINE(); 
	IF @Ln_Error_NUMB <> 50001
	BEGIN
		SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
	END		
	
	SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
	SET @As_Sql_TEXT		      = @Ls_Sql_TEXT;
	SET @As_Sqldata_TEXT	      = @Ls_Sqldata_TEXT;
	SET @An_Error_NUMB		      = @Ln_Error_NUMB;
    SET @An_ErrorLine_NUMB	      = @Ln_ErrorLine_NUMB;
    
  END CATCH
 END
 END;



GO
