/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S120]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S120] (
 @An_OtherParty_IDNO              NUMERIC(9,0),
 @Ac_TypeOthp_CODE                CHAR(1),
 @Ai_RecRank_NUMB                 INT, 	
 @As_OtherParty_NAME              VARCHAR(60) 		OUTPUT,
 @Ac_Aka_NAME                     CHAR(30) 				OUTPUT,
 @Ac_Attn_ADDR                    CHAR(40) 				OUTPUT,
 @As_Line1_ADDR                   VARCHAR(50) 		OUTPUT,
 @As_Line2_ADDR                   VARCHAR(50) 		OUTPUT,
 @Ac_City_ADDR                    CHAR(28) 				OUTPUT,
 @Ac_Zip_ADDR                     CHAR(15) 				OUTPUT,
 @Ac_State_ADDR                   CHAR(2) 				OUTPUT,
 @Ac_Fips_CODE                    CHAR(7) 				OUTPUT,
 @Ac_Country_ADDR                 CHAR(2) 				OUTPUT,
 @Ac_DescriptionContactOther_TEXT CHAR(30) 				OUTPUT,
 @An_Phone_NUMB                   NUMERIC(15,0) 	OUTPUT,
 @An_Fax_NUMB                     NUMERIC(15,0) 	OUTPUT,
 @An_ReferenceOthp_IDNO           NUMERIC(10,0)		OUTPUT,
 @An_NewOtherParty_IDNO           NUMERIC(9,0) 		OUTPUT,
 @An_Fein_IDNO                    NUMERIC(9,0) 		OUTPUT,
 @As_Contact_EML                  VARCHAR(100) 		OUTPUT,
 @An_ParentFein_IDNO              NUMERIC(9,0) 		OUTPUT,
 @Ac_InsuranceProvided_INDC       CHAR(1) 				OUTPUT,
 @An_Sein_IDNO                    NUMERIC(12,0) 	OUTPUT,
 @An_County_IDNO                  NUMERIC(3,0) 		OUTPUT,
 @An_DchCarrier_IDNO              NUMERIC(8,0) 		OUTPUT,
 @Ac_Verified_INDC                CHAR(1) 				OUTPUT,
 @Ac_Eiwn_INDC                    CHAR(1) 				OUTPUT,
 @Ac_Enmsn_INDC                   CHAR(1) 				OUTPUT,
 @Ac_Tribal_CODE                  CHAR(2) 				OUTPUT,
 @Ac_Tribal_INDC                  CHAR(1) 				OUTPUT,
 @Ad_BeginValidity_DATE           DATE 						OUTPUT,
 @Ad_EndValidity_DATE             DATE 						OUTPUT,
 @Ac_WorkerUpdate_ID              CHAR(30) 				OUTPUT,
 @Ad_Update_DTTM                  DATETIME2(0) 		OUTPUT,
 @Ac_SendShort_INDC               CHAR(1) 				OUTPUT,
 @Ac_PpaEiwn_INDC                 CHAR(1) 				OUTPUT,
 @As_DescriptionNotes_TEXT        VARCHAR(4000) 	OUTPUT,
 @Ac_Normalization_CODE           CHAR(1) 				OUTPUT,
 @Ac_EportalSubscription_INDC     CHAR(1) 				OUTPUT,
 @An_BarAtty_NUMB                 NUMERIC(10,0) 	OUTPUT,
 @Ac_ReceivePaperForms_INDC       CHAR(1) 				OUTPUT,
 @Ac_County_NAME                  CHAR(40) 				OUTPUT,
 @An_Corporate_IDNO               NUMERIC(9,0)	 	OUTPUT,
 @As_Corporate_NAME               VARCHAR(60) 		OUTPUT,
 @An_PensionPlanAdmin_IDNO        NUMERIC(9,0) 		OUTPUT,
 @As_PensionPlan_NAME             VARCHAR(60) 		OUTPUT,
 @An_HealthPlanAdmin_IDNO         NUMERIC(9,0) 		OUTPUT,
 @As_HealthPlan_NAME              VARCHAR(60) 		OUTPUT,
 @An_TransactionEventSeq_NUMB     NUMERIC(19,0) 	OUTPUT,
 @An_RowCount_NUMB                NUMERIC(6,0)    OUTPUT
 )
AS
 BEGIN
  /*    
   *     PROCEDURE NAME    : OTHP_RETRIEVE_S120    
   *     DESCRIPTION       : Retrieve Other Party details for a given Other Party number, Other Party TYPE for history popup.   
   *     DEVELOPED BY      : IMP Team    
   *     DEVELOPED ON      : 22-SEP-2011   
   *     MODIFIED BY       :     
   *     MODIFIED ON       :     
   *     VERSION NO        : 1    
   */
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_TypeAddrcp_CODE CHAR(1) = 'Z',
          @Lc_TypeAddrpp_CODE CHAR(1) = 'G',
          @Lc_TypeAddrhp_CODE CHAR(1) = 'V';

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
         @Ac_Verified_INDC = Y.Verified_INDC,
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
         @Ac_ReceivePaperForms_INDC = ReceivePaperForms_INDC,
         @Ac_County_NAME = (SELECT A.County_NAME
                              FROM COPT_Y1 A
                             WHERE A.County_IDNO = Y.County_IDNO),
         @An_Corporate_IDNO = Y.Corporate_NAME,
         @As_Corporate_NAME = (SELECT O.OtherParty_NAME
                                 FROM OTHP_Y1 O
                                WHERE O.OtherParty_IDNO = Y.Corporate_NAME
                                  AND O.EndValidity_DATE = @Ld_High_DATE),
         @An_PensionPlanAdmin_IDNO = Y.PensionPlanAdmin_CODE,
         @As_PensionPlan_NAME = (SELECT O.OtherParty_NAME
                                   FROM OTHP_Y1 O
                                  WHERE O.OtherParty_IDNO = Y.PensionPlanAdmin_CODE
                                    AND O.EndValidity_DATE = @Ld_High_DATE),
         @An_HealthPlanAdmin_IDNO = Y.HealthPlanAdmin_CODE,
         @As_HealthPlan_NAME = (SELECT O.OtherParty_NAME
                                  FROM OTHP_Y1 O
                                 WHERE O.OtherParty_IDNO = Y.HealthPlanAdmin_CODE
                                   AND O.EndValidity_DATE = @Ld_High_DATE),
				 @An_TransactionEventSeq_NUMB = Y.TransactionEventSeq_NUMB,
         @An_RowCount_NUMB = Y.RowCount_NUMB                                    
    FROM (SELECT B.OtherParty_NAME,
                 B.TypeOthp_CODE,
                 B.OtherParty_IDNO,
                 B.Fein_IDNO,
                 B.Sein_IDNO,
                 B.Line1_ADDR,
                 B.Line2_ADDR,
                 B.BeginValidity_DATE,
                 B.EndValidity_DATE,
                 B.ParentFein_IDNO,
                 B.DescriptionContactOther_TEXT,
                 B.InsuranceProvided_INDC,
                 B.BarAtty_NUMB,
                 B.Phone_NUMB,
                 B.Eiwn_INDC,
                 B.Aka_NAME,
                 B.County_IDNO,
                 B.Fax_NUMB,
                 B.Attn_ADDR,
                 B.Fips_CODE,
                 B.DchCarrier_IDNO,
                 B.Contact_EML,
                 B.Zip_ADDR,
                 B.State_ADDR,
                 B.City_ADDR,
                 B.Enmsn_INDC,
                 B.Country_ADDR,
                 B.Tribal_INDC,
                 B.Tribal_CODE,
                 B.Verified_INDC,
                 B.SendShort_INDC,
                 (SELECT C.AddrOthp_IDNO
                    FROM OTHX_Y1 C
                   WHERE C.OtherParty_IDNO = B.OtherParty_IDNO
                     AND C.TypeAddr_CODE = @Lc_TypeAddrcp_CODE
                     AND C.TransactionEventSeq_NUMB = B.TransactionEventSeq_NUMB) AS Corporate_NAME,
                 (SELECT C.AddrOthp_IDNO
                    FROM OTHX_Y1 C
                   WHERE C.OtherParty_IDNO = B.OtherParty_IDNO
                     AND C.TypeAddr_CODE = @Lc_TypeAddrpp_CODE
                     AND C.TransactionEventSeq_NUMB = B.TransactionEventSeq_NUMB) AS PensionPlanAdmin_CODE,
                 (SELECT C.AddrOthp_IDNO
                    FROM OTHX_Y1 C
                   WHERE C.OtherParty_IDNO = B.OtherParty_IDNO
                     AND C.TypeAddr_CODE = @Lc_TypeAddrhp_CODE
                     AND C.TransactionEventSeq_NUMB = B.TransactionEventSeq_NUMB) AS HealthPlanAdmin_CODE,
                 B.PpaEiwn_INDC,
                 B.NewOtherParty_IDNO,
                 B.WorkerUpdate_ID,
                 B.Update_DTTM,
                 B.TransactionEventSeq_NUMB,
                 B.DescriptionNotes_TEXT,
                 B.Normalization_CODE,
                 B.ReferenceOthp_IDNO,
                 B.EportalSubscription_INDC,
                 B.ReceivePaperForms_INDC,
                 ROW_NUMBER() OVER( ORDER BY Update_DTTM DESC) AS RecRank_NUMB,
                 COUNT(1) OVER() AS RowCount_NUMB 
            FROM OTHP_Y1 B
           WHERE B.TypeOthp_CODE = @Ac_TypeOthp_CODE
             AND B.OtherParty_IDNO = @An_OtherParty_IDNO
             AND B.EndValidity_DATE != @Ld_High_DATE ) AS Y
   WHERE Y.RecRank_NUMB = @Ai_RecRank_NUMB;
 END; -- END OF OTHP_RETRIEVE_S120

GO
