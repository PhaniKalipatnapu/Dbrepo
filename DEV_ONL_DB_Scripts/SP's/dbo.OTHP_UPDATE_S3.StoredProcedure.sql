/****** Object:  StoredProcedure [dbo].[OTHP_UPDATE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_UPDATE_S3] (
 @An_OtherParty_IDNO          NUMERIC(9, 0),
 @Ac_EportalSubscription_INDC   CHAR(1),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @An_TransactionEventSeqOld_NUMB NUMERIC(19, 0),
 @Ac_SignedOnWorker_ID CHAR(30)
 )
AS
 /*    
  *     PROCEDURE NAME    : OTHP_UPDATE_S3
  *     DESCRIPTION       : Updates the EPortal Subscription Indicator for the Other Party
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 06/14/2012 
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_Current_DTTM      DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lc_TypeOthpEmployer_CODE CHAR(1) = 'E',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE OTHP_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
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
              @Ld_Current_DATE AS BeginValidity_DATE,
              @Ld_High_DATE AS EndValidity_DATE,
              @Ac_SignedOnWorker_ID AS WorkerUpdate_ID,
              @Ld_Current_DTTM AS Update_DTTM,
              @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
              Deleted.SendShort_INDC,
              Deleted.PpaEiwn_INDC,
              Deleted.DescriptionNotes_TEXT,
              Deleted.Normalization_CODE,
              @Ac_EportalSubscription_INDC AS EportalSubscription_INDC,
              Deleted.BarAtty_NUMB,
              Deleted.ReceivePaperForms_INDC
    INTO OTHP_Y1
   WHERE OtherParty_IDNO = @An_OtherParty_IDNO
     AND TypeOthp_CODE = @Lc_TypeOthpEmployer_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; -- END OF OTHP_UPDATE_S3


GO
