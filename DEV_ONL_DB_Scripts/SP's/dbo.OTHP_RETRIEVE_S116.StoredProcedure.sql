/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S116]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S116] (
 @An_OtherParty_IDNO              NUMERIC(9, 0),
 @An_TransactionEventSeq_NUMB     NUMERIC(19, 0),
 @As_OtherParty_NAME              VARCHAR(60) OUTPUT,
 @Ac_Aka_NAME                     CHAR(30) OUTPUT,
 @Ac_Attn_ADDR                    CHAR(40) OUTPUT,
 @As_Line1_ADDR                   VARCHAR(50) OUTPUT,
 @As_Line2_ADDR                   VARCHAR(50) OUTPUT,
 @Ac_City_ADDR                    CHAR(28) OUTPUT,
 @Ac_Zip_ADDR                     CHAR(15) OUTPUT,
 @Ac_State_ADDR                   CHAR(2) OUTPUT,
 @Ac_Fips_CODE                    CHAR(7) OUTPUT,
 @Ac_Country_ADDR                 CHAR(2) OUTPUT,
 @Ac_DescriptionContactOther_TEXT CHAR(30) OUTPUT,
 @An_Phone_NUMB                   NUMERIC(15, 0) OUTPUT,
 @An_Fax_NUMB                     NUMERIC(15, 0) OUTPUT,
 @An_ReferenceOthp_IDNO           NUMERIC(10, 0) OUTPUT,
 @An_NewOtherParty_IDNO           NUMERIC(9, 0) OUTPUT,
 @An_Fein_IDNO                    NUMERIC(9, 0) OUTPUT,
 @As_Contact_EML                  VARCHAR(100) OUTPUT,
 @An_ParentFein_IDNO              NUMERIC(9, 0) OUTPUT,
 @Ac_InsuranceProvided_INDC       CHAR(1) OUTPUT,
 @An_Sein_IDNO                    NUMERIC(12, 0) OUTPUT,
 @An_County_IDNO                  NUMERIC(3, 0) OUTPUT,
 @An_DchCarrier_IDNO              NUMERIC(8, 0) OUTPUT,
 @Ac_Nsf_INDC                     CHAR(1) OUTPUT,
 @Ac_Verified_INDC                CHAR(1) OUTPUT,
 @Ac_Note_INDC                    CHAR(1) OUTPUT,
 @Ac_Eiwn_INDC                    CHAR(1) OUTPUT,
 @Ac_Enmsn_INDC                   CHAR(1) OUTPUT,
 @Ac_Tribal_CODE                  CHAR(2) OUTPUT,
 @Ac_Tribal_INDC                  CHAR(1) OUTPUT,
 @Ad_BeginValidity_DATE           DATE OUTPUT,
 @Ad_EndValidity_DATE             DATE OUTPUT,
 @Ac_WorkerUpdate_ID              CHAR(30) OUTPUT,
 @Ad_Update_DTTM                  DATETIME2(0) OUTPUT,
 @Ac_SendShort_INDC               CHAR(1) OUTPUT,
 @Ac_PpaEiwn_INDC                 CHAR(1) OUTPUT,
 @As_DescriptionNotes_TEXT        VARCHAR(4000) OUTPUT,
 @Ac_Normalization_CODE           CHAR(1) OUTPUT,
 @Ac_EportalSubscription_INDC     CHAR(1) OUTPUT,
 @An_BarAtty_NUMB                 NUMERIC(10, 0) OUTPUT,
 @Ac_ReceivePaperForms_INDC       CHAR(1) OUTPUT
 )
AS
 BEGIN
  /*    
   *     PROCEDURE NAME    : OTHP_RETRIEVE_S116    
   *     DESCRIPTION       : Retrieve Other Party details for a given Other Party number, Other Party TYPE.   
   *     DEVELOPED BY      : IMP Team    
   *     DEVELOPED ON      : 22-SEP-2011   
   *     MODIFIED BY       :     
   *     MODIFIED ON       :     
   *     VERSION NO        : 1    
   */
  DECLARE @Ld_High_DATE             DATE = '12/31/9999',
          @Lc_TypeOthpEmployer_CODE CHAR(1) = 'E';

  SELECT @As_OtherParty_NAME = Y.OtherParty_NAME,
         @Ac_Aka_NAME = Y.Aka_NAME,
         @Ac_Attn_ADDR = Y.Attn_ADDR,
         @As_Line1_ADDR = Y.Line1_ADDR,
         @As_Line2_ADDR = Y.Line2_ADDR,
         @Ac_City_ADDR = Y.City_ADDR,
         @Ac_Zip_ADDR = Y.Zip_ADDR,
         @Ac_State_ADDR = Y.State_ADDR,
         @Ac_Fips_CODE = Y.Fips_CODE,
         @Ac_Country_ADDR = Y.Country_ADDR,
         @Ac_DescriptionContactOther_TEXT = Y.DescriptionContactOther_TEXT,
         @An_Phone_NUMB = Y.Phone_NUMB,
         @An_Fax_NUMB = Y.Fax_NUMB,
         @An_ReferenceOthp_IDNO = Y.ReferenceOthp_IDNO,
         @An_NewOtherParty_IDNO = Y.NewOtherParty_IDNO,
         @An_Fein_IDNO = Y.Fein_IDNO,
         @As_Contact_EML = Y.Contact_EML,
         @An_ParentFein_IDNO = Y.ParentFein_IDNO,
         @Ac_InsuranceProvided_INDC = Y.InsuranceProvided_INDC,
         @An_Sein_IDNO = Y.Sein_IDNO,
         @An_County_IDNO = Y.County_IDNO,
         @An_DchCarrier_IDNO = Y.DchCarrier_IDNO,
         @Ac_Nsf_INDC = Y.Nsf_INDC,
         @Ac_Verified_INDC = Y.Verified_INDC,
         @Ac_Note_INDC = Y.Note_INDC,
         @Ac_Eiwn_INDC = Y.Eiwn_INDC,
         @Ac_Enmsn_INDC = Y.Enmsn_INDC,
         @Ac_Tribal_CODE = Y.Tribal_CODE,
         @Ac_Tribal_INDC = Y.Tribal_INDC,
         @Ad_BeginValidity_DATE = Y.BeginValidity_DATE,
         @Ad_EndValidity_DATE = Y.EndValidity_DATE,
         @Ac_WorkerUpdate_ID = Y.WorkerUpdate_ID,
         @Ad_Update_DTTM = Y.Update_DTTM,
         @Ac_SendShort_INDC = Y.SendShort_INDC,
         @Ac_PpaEiwn_INDC = Y.PpaEiwn_INDC,
         @As_DescriptionNotes_TEXT = Y.DescriptionNotes_TEXT,
         @Ac_Normalization_CODE = Y.Normalization_CODE,
         @Ac_EportalSubscription_INDC = Y.EportalSubscription_INDC,
         @An_BarAtty_NUMB = Y.BarAtty_NUMB,
         @Ac_ReceivePaperForms_INDC = ReceivePaperForms_INDC
    FROM OTHP_Y1 Y
   WHERE Y.TypeOthp_CODE = @Lc_TypeOthpEmployer_CODE
     AND Y.OtherParty_IDNO = @An_OtherParty_IDNO
     AND Y.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND Y.EndValidity_DATE = @Ld_High_DATE;
 END; -- 

GO
