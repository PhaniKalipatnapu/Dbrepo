/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S20]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S20]  
(
 @Ac_StatusCheck_CODE		CHAR(2)		,
 @Ac_ReasonStatus_CODE		CHAR(2)		,
 @Ac_CheckRecipient_CODE	CHAR(1)     ,
 @Ad_From_DATE				DATE		,
 @Ad_To_DATE				DATE		,
 @Ai_RowFrom_NUMB     		INT=1       ,
 @Ai_RowTo_NUMB       		INT=10      
)                                                                    
AS

/*
 *     PROCEDURE NAME    : DSBH_RETRIEVE_S20
 *     DESCRIPTION       : Retrieve Details of all Disbursements that have been stopped or voided for a date range.
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 01-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      DECLARE
	      @Lc_StatusCheckVoid_CODE		CHAR(1)	= 'V'		,
    	  @Lc_StatusCheckStop_CODE		CHAR(1)	= 'S'		,
    	  @Lc_MediumDisburseC_CODE      CHAR(1) = 'C'		,
          @Lc_Empty_TEXT			    CHAR(1) = ''		,    
		  @Lc_Percentage_TEXT			CHAR(1) = '%' 		,
		  @Lc_SubTypeAddressCol_CODE    CHAR(3) = 'COL'		,
          @Lc_SubTypeAddressFrc_CODE    CHAR(3) = 'FRC'		,
          @Lc_SubTypeAddressSdu_CODE	CHAR(3) = 'SDU'		,
          @Lc_TypeAddressInt_CODE		CHAR(3) = 'INT'		,
          @Lc_TypeAddressLocate_CODE	CHAR(3) = 'LOC'		,
          @Lc_TypeAddressState_CODE		CHAR(3) = 'STA'		,
		  @Lc_CheckRecipient_ID			CHAR(9)	= '999999980' , 
		  @Lc_MemberSSN_CODE			CHAR(9) = '000000000',
		  @Li_Zero_NUMB					SMALLINT=0 			,
		  @Ld_High_DATE					DATE	= '12/31/9999'; 
                                                                  
	SELECT Y.CheckRecipient_ID,
		 Y.CheckRecipient_CODE,
         Y.Disburse_DATE , 
         Y.MediumDisburse_CODE,
         Y.Disburse_AMNT , 
         Y.Check_NUMB ,
         Y.StatusCheck_CODE ,
         Y.StatusCheck_DATE, 
         Y.ReasonStatus_CODE, 
         (SELECT TOP 1 UR.HighProfile_INDC
               FROM USRT_Y1 UR
              WHERE UR.MemberMci_IDNO = Y.CheckRecipient_ID
                AND UR.EndValidity_DATE = @Ld_High_DATE) AS HighProfile_INDC ,
         (SELECT TOP 1 FI.Fips_NAME
                                     FROM FIPS_Y1 FI
                                    WHERE FI.Fips_CODE = CAST(Y.CheckRecipient_ID AS CHAR)
                                      AND ((FI.TypeAddress_CODE = @Lc_TypeAddressState_CODE
                                            AND FI.SubTypeAddress_CODE = @Lc_SubTypeAddressSdu_CODE)
                                            OR (FI.TypeAddress_CODE = @Lc_TypeAddressLocate_CODE
                                                AND FI.SubTypeAddress_CODE = @Lc_SubTypeAddressCol_CODE)
                                            OR (FI.TypeAddress_CODE = @Lc_TypeAddressInt_CODE
                                                AND FI.SubTypeAddress_CODE = @Lc_SubTypeAddressFrc_CODE))
                                      AND FI.EndValidity_DATE = @Ld_High_DATE) AS Fips_NAME , 
         (SELECT TOP 1 OTH.OtherParty_NAME
                                    FROM OTHP_Y1 OTH
                                   WHERE OTH.OtherParty_IDNO = Y.CheckRecipient_ID
                                     AND OTH.EndValidity_DATE = @Ld_High_DATE
                                   ORDER BY OTH.TransactionEventSeq_NUMB DESC) AS OtherParty_NAME,
         D.Restricted_INDC,
         D.Last_NAME,
         D.Suffix_NAME,
         D.First_NAME,
         D.Middle_NAME,
         ISNULL(D.MemberSsn_NUMB,@Lc_MemberSSN_CODE ) MemberSsn_NUMB,
         Y.TotalAmount_AMNT , 
         Y.Case_IDNO, 
         Y.Worker_ID, 
         Y.RowCount_NUMB 
      FROM ( 
        SELECT X.MediumDisburse_CODE,
               X.Check_NUMB ,
               X.Disburse_DATE, 
               X.Disburse_AMNT, 
               X.StatusCheck_DATE, 
               X.ReasonStatus_CODE, 
               X.StatusCheck_CODE, 
               X.CheckRecipient_CODE, 
               X.CheckRecipient_ID,
               X.TotalAmount_AMNT, 
               X.RowCount_NUMB, 
               X.ORD_ROWNUM,  
               X.Case_IDNO, 
               X.Worker_ID
            FROM  ( 
              SELECT ISNULL(a.MediumDisburse_CODE, @Lc_Empty_TEXT) MediumDisburse_CODE ,
                     a.Check_NUMB ,
                     a.Disburse_DATE , 
                     SUM(z.Disburse_AMNT) AS Disburse_AMNT, 
                     a.StatusCheck_DATE , 
                     a.ReasonStatus_CODE , 
                     a.StatusCheck_CODE , 
                     a.CheckRecipient_CODE , 
                     a.CheckRecipient_ID , 
                     SUM(SUM(z.Disburse_AMNT)) OVER() AS TotalAmount_AMNT, 
                     COUNT(1) OVER() AS RowCount_NUMB, 
                     z.Case_IDNO, 
                     x.Worker_ID , 
                     ROW_NUMBER() OVER(
                        ORDER BY a.ReasonStatus_CODE, a.StatusCheck_CODE) AS ORD_ROWNUM
                  FROM DSBH_Y1  a
                    JOIN DSBL_Y1  z
						ON   a.CheckRecipient_ID = z.CheckRecipient_ID 
						AND  a.CheckRecipient_CODE = z.CheckRecipient_CODE 
						AND  a.Disburse_DATE = z.Disburse_DATE 
						AND  a.DisburseSeq_NUMB = z.DisburseSeq_NUMB 
					JOIN GLEV_Y1  x 
						ON	a.EventGlobalBeginSeq_NUMB = x.EventGlobalSeq_NUMB 
                  WHERE a.StatusCheck_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE 
                    AND a.MediumDisburse_CODE = @Lc_MediumDisburseC_CODE 
                    AND a.CheckRecipient_ID<> @Lc_CheckRecipient_ID 
                    AND (
                    ((     @Ac_StatusCheck_CODE IS NOT NULL 
                      AND @Ac_ReasonStatus_CODE IS NOT NULL 
                      AND LTRIM(RTRIM(a.StatusCheck_CODE))LIKE LTRIM(RTRIM(@Ac_StatusCheck_CODE)) + @Lc_Percentage_TEXT 
                      AND LTRIM(RTRIM(a.ReasonStatus_CODE)) LIKE LTRIM(RTRIM(@Ac_ReasonStatus_CODE)) + @Lc_Percentage_TEXT) 
                   OR ( @Ac_StatusCheck_CODE IS NOT NULL 
                    AND @Ac_ReasonStatus_CODE IS NULL 
                    AND LTRIM(RTRIM(a.StatusCheck_CODE)) LIKE LTRIM(RTRIM(@Ac_StatusCheck_CODE))+ @Lc_Percentage_TEXT)) 
							OR (@Ac_StatusCheck_CODE IS NULL 
							AND (LTRIM(RTRIM(a.StatusCheck_CODE)) LIKE @Lc_StatusCheckStop_CODE + @Lc_Percentage_TEXT 
								OR LTRIM(RTRIM(a.StatusCheck_CODE)) LIKE @Lc_StatusCheckVoid_CODE + @Lc_Percentage_TEXT))) 
				  AND a.CheckRecipient_CODE = ISNULL(@Ac_CheckRecipient_CODE,a.CheckRecipient_CODE) 
				  AND a.EndValidity_DATE = @Ld_High_DATE 
                  GROUP BY 
                     a.MediumDisburse_CODE, 
                     a.Check_NUMB, 
                     a.Misc_ID, 
                     a.Disburse_DATE, 
                     a.Disburse_AMNT, 
                     a.StatusCheck_DATE, 
                     a.ReasonStatus_CODE, 
                     a.StatusCheck_CODE, 
                     a.CheckRecipient_ID, 
                     a.StatusCheck_CODE, 
                     a.CheckRecipient_CODE, 
                     a.CheckRecipient_ID, 
                     z.Case_IDNO, 
                     x.Worker_ID

               )  AS X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB 
				OR (@Ai_RowTo_NUMB = @Li_Zero_NUMB)
         )  AS Y
          LEFT OUTER JOIN DEMO_Y1 D
            ON (Y.CheckRecipient_ID = D.MemberMci_IDNO)
      WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB 
		 OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
ORDER BY ORD_ROWNUM;

                  
END; --END OF DSBH_RETRIEVE_S20


GO
