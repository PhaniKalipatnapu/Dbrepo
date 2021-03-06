/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S30] (
 @An_Case_IDNO			NUMERIC(6, 0),
 @Ad_From_DATE          DATE,
 @Ad_To_DATE            DATE
 )
AS
 /*
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S30
  *     DESCRIPTION       : Retrieves the total disburse amount for the given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-SEP-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN

	DECLARE @Lc_CheckRecipientCpNcp_CODE		CHAR(1) = '1',
			@Lc_CheckRecipientFips_CODE			CHAR(1) = '2',
			@Lc_CheckRecipientOthp_CODE			CHAR(1) = '3',
			@Lc_MediumDisburseB_CODE			CHAR(1) = 'B',
			@Lc_MediumDisburseC_CODE			CHAR(1) = 'C',
			@Lc_MediumDisburseE_CODE			CHAR(1) = 'E',
			@Lc_StatusCheckRe_CODE				CHAR(2) = 'RE',
			@Lc_StatusCheckVn_CODE				CHAR(2) = 'VN',
			@Lc_StatusCheckVr_CODE				CHAR(2) = 'VR',
			@Lc_StatusCheckSr_CODE				CHAR(2) = 'SR',
			@Lc_StatusCheckSn_CODE				CHAR(2) = 'SN',
			@Lc_TypeAddressLoc_CODE				CHAR(3) = 'LOC',
			@Lc_SubTypeAddressC01_CODE			CHAR(3) = 'C01',
			@Lc_TypeDisburseRefnd_CODE			CHAR(5) = 'REFND',
			@Lc_TypeDisburseRothp_CODE			CHAR(5) = 'ROTHP',
			@Ld_High_DATE						DATE = '12/31/9999';

  SELECT A.Disburse_DATE,
       CASE
        WHEN CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
         THEN (SELECT Last_Name + ' ' + First_NAME + ' ' + Middle_NAME
                 FROM DEMO_Y1 D
                 WHERE D.MemberMci_IDNO = A.CheckRecipient_ID)
        WHEN CheckRecipient_CODE = @Lc_CheckRecipientFips_CODE
         THEN (SELECT Fips_NAME
                 FROM FIPS_Y1 F
                WHERE F.Fips_CODE = A.CheckRecipient_ID
                  AND F.EndValidity_DATE = @Ld_High_DATE
                  AND F.TypeAddress_CODE = @Lc_TypeAddressLoc_CODE
                  AND F.SubTypeAddress_CODE = @Lc_SubTypeAddressC01_CODE)
        WHEN CheckRecipient_CODE = @Lc_CheckRecipientOthp_CODE
         THEN (SELECT OtherParty_NAME
                 FROM OTHP_Y1 O
                WHERE O.OtherParty_IDNO = A.CheckRecipient_ID
                  AND O.EndValidity_DATE = @Ld_High_DATE)
       END Recipient_NAME,
       CASE
        WHEN MediumDisburse_CODE = @Lc_MediumDisburseC_CODE
         THEN Check_NUMB
        WHEN MediumDisburse_CODE = @Lc_MediumDisburseB_CODE
         THEN (SELECT TOP 1 SUBSTRING(CONVERT(VARCHAR(23), AccountBankNo_TEXT),1,15)
                 FROM DCRS_Y1 B
                WHERE B.CheckRecipient_ID = A.CheckRecipient_ID
                  AND EndValidity_DATE = @Ld_High_DATE)
        WHEN MediumDisburse_CODE = @Lc_MediumDisburseE_CODE
         THEN (SELECT TOP 1 CONVERT(VARCHAR(23), RoutingBank_NUMB)
                 FROM EFTR_Y1 B
                WHERE B.CheckRecipient_CODE = A.CheckRecipient_CODE
                  AND B.CheckRecipient_ID = A.CheckRecipient_ID
                  AND EndValidity_DATE = @Ld_High_DATE)
       END Instrument_NUMB,
       Disburse_AMNT,
       COUNT(1) over()RowCount_NUMB
  FROM (SELECT Case_IDNO,
               A.Disburse_DATE,
               A.CheckRecipient_ID,
               A.CheckRecipient_CODE,
               B.MediumDisburse_CODE,
               Check_NUMB,
               ISNULL(SUM(CONVERT(FLOAT, A.Disburse_AMNT)), 0) AS Disburse_AMNT
          FROM DSBL_Y1 A, DSBH_Y1 B
         WHERE A.Case_IDNO = @An_Case_IDNO
           AND A.Disburse_DATE = B.Disburse_DATE
           AND A.DisburseSeq_NUMB = B.DisburseSeq_NUMB
           AND A.CheckRecipient_ID = B.CheckRecipient_ID
           AND A.CheckRecipient_CODE = B.CheckRecipient_CODE
           AND B.StatusCheck_CODE NOT IN (@Lc_StatusCheckRe_CODE, @Lc_StatusCheckVn_CODE, @Lc_StatusCheckVr_CODE, 
															@Lc_StatusCheckSr_CODE, @Lc_StatusCheckSn_CODE)
           AND B.EndValidity_DATE = @Ld_High_DATE
           AND B.Disburse_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
           AND TypeDisburse_CODE NOT IN (@Lc_TypeDisburseRefnd_CODE, @Lc_TypeDisburseRothp_CODE)
         GROUP BY Case_IDNO,
                  A.Disburse_DATE,
                  A.CheckRecipient_ID,
                  A.CheckRecipient_CODE,
                  B.MediumDisburse_CODE,
                  Check_NUMB) A
	ORDER BY A.Disburse_DATE DESC;

 END; --End of DSBL_RETRIEVE_S30


GO
