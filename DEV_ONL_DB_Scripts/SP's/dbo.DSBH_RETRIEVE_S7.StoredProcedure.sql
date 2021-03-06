/****** Object:  StoredProcedure [dbo].[DSBH_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DSBH_RETRIEVE_S7] (
 @Ac_CheckRecipient_ID   CHAR(10),
 @Ac_CheckRecipient_CODE CHAR(1),
 @An_Check_NUMB          NUMERIC(19),
 @Ad_DisburseFrom_DATE   DATE,
 @Ad_DisburseTo_DATE     DATE,
 @An_Case_IDNO           NUMERIC(6),
 @Ac_Misc_ID             CHAR(11),
 @Ac_StatusCheck_CODE    CHAR(2),
 @Ac_DisbursementTo_CODE CHAR(1),
 @Ac_MediumDisburse_CODE CHAR(1),
 @Ai_RowFrom_NUMB        INT =1,
 @Ai_RowTo_NUMB          INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : DSBH_RETRIEVE_S7
  *     DESCRIPTION       : Retrieves the disbursement records for a Funds Recipient ID, a Case ID and a Check Number in cases of check disbursement or a Control Number in cases of EFT/Stored Value card.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01-dec-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCheckAll_CODE						CHAR(1)		= 'A',
          @Lc_MediumDisburseSvc_CODE					CHAR(1)		= 'B',
          @Lc_MediumDisburseCheck_CODE					CHAR(1)		= 'C',
          @Lc_MediumDisburseEft_CODE					CHAR(1)		= 'E',
          @Lc_CheckRecipientOthp_CODE					CHAR(1)		= '3',
          @Lc_Yes_TEXT									CHAR(1)		= 'Y',
          @Lc_No_TEXT									CHAR(1)		= 'N',
          @Lc_StatusCheckOutstanding_CODE				CHAR(2)		= 'OU',
          @Lc_StatusCheckEftTransfer_CODE				CHAR(2)		= 'TR',
          @Lc_StatusCheckCashed_CODE					CHAR(2)		= 'CA',
          @Lc_StatusCheckRejectedEft_CODE				CHAR(2)		= 'RE',
          @Lc_StatusCheckPs_CODE						CHAR(2)		= 'PS',
          @Lc_HyphenWithSpace_TEXT                      CHAR(3)		= ' - ',
          @Lc_CheckRecipientOutOfStateRecovery_ID		CHAR(10)	= '999999980',
          @Ld_High_DATE									DATE		= '12/31/9999';
  DECLARE @Lc_DisburseFromDate_TEXT						CHAR(10),
          @Lc_DisburseToDate_TEXT						CHAR(10),
          @Ls_SqlCaseIdno_TEXT							VARCHAR(4000),
          @Ls_SqlDisburseWhere_TEXT						VARCHAR(4000),
          @Ls_SqlSelect_TEXT							VARCHAR(MAX),
          @Ls_SqlWhere_TEXT								VARCHAR(MAX),
          @Ls_SqlTemp_TEXT								VARCHAR(MAX);

  IF @An_Check_NUMB IS NULL
   BEGIN
    IF @Ad_DisburseFrom_DATE IS NOT NULL
       AND @Ad_DisburseTo_DATE IS NOT NULL
     BEGIN
      SET @Lc_DisburseFromDate_TEXT = CONVERT(VARCHAR(10), @Ad_DisburseFrom_DATE, 101);
      SET @Lc_DisburseToDate_TEXT= CONVERT(VARCHAR(10), @Ad_DisburseTo_DATE, 101);
     END;
   END;

  IF @An_Check_NUMB IS NOT NULL
   BEGIN
    SET @Ls_SqlWhere_TEXT = '
     AND  a.Check_NUMB      != ''0''
     AND  a.Check_NUMB      = RTRIM(LTRIM(''' + CAST(@An_Check_NUMB AS VARCHAR) + '''))';
   END;

  -- If the control number is not null then it will display all rows matched with the given control number
  IF @Ac_Misc_ID IS NOT NULL
   BEGIN
    SET @Ls_SqlWhere_TEXT = '
        AND a.Misc_ID      != ''0''
        AND a.Misc_ID      = RTRIM(LTRIM(''' + @Ac_Misc_ID + '''))';
   END;

  /*  If the input values of CheckRecipient_ID and CheckRecipient_CODE are not null,
    then all records will be displayed with that corresponding CheckRecipient_ID and the recipient type
    This condition is used while clicking view disbusements for fund recipient screen function
   */
  IF @Ac_CheckRecipient_ID IS NOT NULL
     AND @Ac_CheckRecipient_CODE IS NOT NULL
   BEGIN -- starts - To display all the rows when no dates entered
    IF @Ad_DisburseFrom_DATE IS NULL
       AND @Ad_DisburseTo_DATE IS NULL
     BEGIN
      SET @Ls_SqlWhere_TEXT = ' AND a.CheckRecipient_ID = ''' + CAST(@Ac_CheckRecipient_ID AS VARCHAR) + '''
                     AND CheckRecipient_CODE = ''' + @Ac_CheckRecipient_CODE + '''';
     -- To display all rows for the entered from and to dates and the entered CheckRecipient_ID
     END
    ELSE
     BEGIN--For options 1,2,3
      SET @Ls_SqlWhere_TEXT = ' AND a.CheckRecipient_ID = ''' + CAST(@Ac_CheckRecipient_ID AS VARCHAR) + '''
                     AND CheckRecipient_CODE = ''' + @Ac_CheckRecipient_CODE + '''
                     AND a.Disburse_DATE BETWEEN ''' + @Lc_DisburseFromDate_TEXT + ''' AND ''' + @Lc_DisburseToDate_TEXT + '''';
     END;

    --  ends
    /*  If the id_case is entered, then it will display all the records matched with the  entered
       id_case and CheckRecipient_ID.
     */
    IF RTRIM(LTRIM(@An_Case_IDNO)) IS NOT NULL
     BEGIN
      SET @Ls_SqlWhere_TEXT = @Ls_SqlWhere_TEXT + ' AND  EXISTS (SELECT 1 FROM DSBL_Y1 c
                                 WHERE c.CheckRecipient_ID = ''' + CAST(@Ac_CheckRecipient_ID AS VARCHAR) + '''
                          AND c.CheckRecipient_CODE = ''' + @Ac_CheckRecipient_CODE + '''
                                   AND c.Disburse_DATE    = a.Disburse_DATE
                                   AND c.DisburseSeq_NUMB     = a.DisburseSeq_NUMB
                                   AND c.Case_IDNO          = ''' + CAST (@An_Case_IDNO AS VARCHAR) + ''')';
     END;
   /*  If the Case_IDNO is entered, then it will display all the records matched with the entered
      Case_IDNO. This condition is used while clicking the view disbursements by case screen function
    */
   END;
  ELSE IF @An_Case_IDNO IS NOT NULL
   BEGIN
    -- starts - To display all the rows when no dates entered
    IF @Ad_DisburseFrom_DATE IS NULL
       AND @Ad_DisburseTo_DATE IS NULL
     BEGIN
      SET @Ls_SqlWhere_TEXT = ' --AND a.CheckRecipient_ID != ''' + @Lc_CheckRecipientOutOfStateRecovery_ID + ''' 
                AND  EXISTS (SELECT 1 FROM DSBL_Y1 c
                                     WHERE c.CheckRecipient_ID = a.CheckRecipient_ID
                                       AND c.CheckRecipient_CODE = a.CheckRecipient_CODE
                                       AND c.Disburse_DATE      = a.Disburse_DATE
                                       AND c.DisburseSeq_NUMB     = a.DisburseSeq_NUMB
                                       AND c.Case_IDNO          = ''' + CAST(@An_Case_IDNO AS VARCHAR) + ''')';
     END
    -- To display all records between the given from and to dates for the entered Case_IDNO
    ELSE
     BEGIN --For option 4
      SET @Ls_SqlWhere_TEXT = ' --AND a.CheckRecipient_ID != ''' + @Lc_CheckRecipientOutOfStateRecovery_ID + ''' 
                AND  a.Disburse_DATE BETWEEN ''' + @Lc_DisburseFromDate_TEXT + ''' AND ''' + @Lc_DisburseToDate_TEXT + '''
                     AND  EXISTS (SELECT 1 FROM DSBL_Y1 c
                                   WHERE c.CheckRecipient_ID = a.CheckRecipient_ID
                                     AND c.CheckRecipient_CODE = a.CheckRecipient_CODE
                                     AND c.Disburse_DATE      = a.Disburse_DATE
                                     AND c.DisburseSeq_NUMB     = a.DisburseSeq_NUMB
                                     AND c.Case_IDNO          = ''' + CAST(@An_Case_IDNO AS VARCHAR) + ''')';
     END;

    --  ends
    -- To select all rows matched with the given to_date, if the to_date is not null
    IF @Ac_DisbursementTo_CODE IS NOT NULL
     BEGIN
      SET @Ls_SqlWhere_TEXT = @Ls_SqlWhere_TEXT + ' AND a.CheckRecipient_CODE = ''' + @Ac_DisbursementTo_CODE + '''';
     END;
   END;

  -- To check the Refund disbursement type, if the type is 'A', then include the condtion for StatusCheck_CODE
  IF @Ac_StatusCheck_CODE != @Lc_StatusCheckAll_CODE
   BEGIN
    SET @Ls_SqlWhere_TEXT = @Ls_SqlWhere_TEXT + ' AND a.StatusCheck_CODE = ''' + @Ac_StatusCheck_CODE + ''' ';
   END;

  -- If the Case_IDNO has value and then calulate the Disburse_AMNT for the corresponding CheckRecipient_CODE(1 or 3)
  IF RTRIM(LTRIM(@An_Case_IDNO)) IS NOT NULL
   BEGIN
    SET @Ls_SqlCaseIdno_TEXT = '''' + CAST(@An_Case_IDNO AS VARCHAR) + '''Case_IDNO';
    SET @Ls_SqlDisburseWhere_TEXT = ' CASE WHEN CheckRecipient_CODE = ''' + @Lc_CheckRecipientOthp_CODE + '''  THEN
                         (SELECT ISNULL(SUM(Disburse_AMNT), 0) FROM DSBL_Y1 c
             WHERE c.CheckRecipient_ID = a.CheckRecipient_ID
               AND CheckRecipient_CODE = a.CheckRecipient_CODE
                AND c.Disburse_DATE    = a.Disburse_DATE
                AND DisburseSeq_NUMB    = a.DisburseSeq_NUMB
                AND c.Case_IDNO      = ''' + CAST(@An_Case_IDNO AS VARCHAR) + ''')
           ELSE a.Disburse_AMNT
         END Case_AMNT';
   -- If the Case_IDNO has no value and then calulate the Disburse_AMNT for the corresponding CheckRecipient_CODE(1 or 3)
   END
  ELSE
   BEGIN
    SET @Ls_SqlCaseIdno_TEXT = ' CASE WHEN CheckRecipient_CODE = ''' + @Lc_CheckRecipientOthp_CODE + '''  THEN null
                          ELSE (SELECT TOP 1 Case_IDNO
                    FROM DSBL_Y1 c
                   WHERE c.CheckRecipient_ID  = a.CheckRecipient_ID
                                   AND c.CheckRecipient_CODE = a.CheckRecipient_CODE
                                   AND c.DisburseSeq_NUMB    = a.DisburseSeq_NUMB
                                   AND  c.Disburse_DATE    = a.Disburse_DATE
                                   )
         END Case_IDNO ';
    SET @Ls_SqlDisburseWhere_TEXT = 'CASE WHEN CheckRecipient_CODE = ''' + @Lc_CheckRecipientOthp_CODE + '''  THEN 0
                         ELSE a.Disburse_AMNT
                    END Case_AMNT';
   END;

  /* If the medium_disburse_type is not null, then include the condition for checking
    the MediumDisburse_CODE type is B,C or E
   */
  IF @Ac_MediumDisburse_CODE IS NOT NULL
   BEGIN
    SET @Ls_SqlWhere_TEXT = @Ls_SqlWhere_TEXT + ' AND a.MediumDisburse_CODE = ''' + @Ac_MediumDisburse_CODE + ''' ';
   END;

  SET @Ls_SqlSelect_TEXT = 'SELECT CheckNumb_TEXT,Check_NUMB,
            StatusCheck_DATE,
            Disburse_AMNT,
            Disburse_DATE,
            DisburseSeq_NUMB,
            CheckRecipient_ID,
            CheckRecipient_CODE,
            StatusCheck_CODE,
            VoidAction_CODE,
            ReasonStatus_CODE,
            ISNULL((SELECT TOP 1 t.MediumDisburse_CODE+'' - ''+ CASE WHEN t.CheckCount_NUMB > 1
									  THEN ''MULTIPLE''
								 WHEN t.MediumDisburse_CODE = '''+@Lc_MediumDisburseCheck_CODE+''' 
									  THEN CAST(t.Check_NUMB AS CHAR) 
								 ELSE t.Misc_ID
						   END 
					 FROM (SELECT b.Check_NUMB,b.Misc_ID, b.MediumDisburse_CODE, COUNT(*) OVER(PARTITION BY b.CheckRecipient_ID, b.Disburse_DATE) CheckCount_NUMB 
							   FROM DSBC_Y1 AS x,
									DSBH_Y1 AS b
							 WHERE x.CheckRecipientOrig_ID = a.CheckRecipient_ID
								AND x.CheckRecipientOrig_CODE = a.CheckRecipient_CODE
								AND x.DisburseOrig_DATE =a.Disburse_DATE
								AND x.DisburseOrigSeq_NUMB = a.DisburseSeq_NUMB
								AND b.CheckRecipient_ID = x.CheckRecipient_ID
								AND b.CheckRecipient_CODE = x.CheckRecipient_CODE
								AND b.Disburse_DATE = x.Disburse_DATE
								AND b.DisburseSeq_NUMB = x.DisburseSeq_NUMB
								AND b.Check_NUMB != 0
								AND b.EndValidity_DATE = ''' + CAST(@Ld_High_DATE AS CHAR(10)) + '''	
								) AS t)
				,'''') AS CheckReplaceNumb_TEXT,
            Worker_ID,
            MediumDisburse_CODE,
            EventGlobalBeginSeq_NUMB,
            UpdateFlag_INDC,
            StatusCheckOld_CODE, ' + @Ls_SqlCaseIdno_TEXT + ' , ' + @Ls_SqlDisburseWhere_TEXT + ' ,RowCount_NUMB
            FROM
            (
            select CheckNumb_TEXT,Check_NUMB,
            StatusCheck_DATE,
            Disburse_AMNT,
            Disburse_DATE,
            DisburseSeq_NUMB,
            CheckRecipient_ID,
            CheckRecipient_CODE,
            StatusCheck_CODE,
            VoidAction_CODE,
            ReasonStatus_CODE,
            Worker_ID,
            MediumDisburse_CODE,
            EventGlobalBeginSeq_NUMB,
            UpdateFlag_INDC,
            StatusCheckOld_CODE,
            RowCount_NUMB,
            rnum AS rnum1
            FROM
            (
             SELECT MediumDisburse_CODE +''' + @Lc_HyphenWithSpace_TEXT + '''+(CASE MediumDisburse_CODE
                       WHEN ''' + @Lc_MediumDisburseSvc_CODE + ''' THEN a.Misc_ID
                       WHEN ''' + @Lc_MediumDisburseEft_CODE + ''' THEN a.Misc_ID
                       WHEN ''' + @Lc_MediumDisburseCheck_CODE + ''' THEN CAST(a.Check_NUMB AS VARCHAR)
                       ELSE NULL
                       END ) CheckNumb_TEXT,
                       a.Check_Numb,
          a.StatusCheck_DATE ,
          a.Disburse_AMNT,
          a.Disburse_DATE,
          a.DisburseSeq_NUMB,
          a.CheckRecipient_ID,
          a.CheckRecipient_CODE,
           a.StatusCheck_CODE,
          (CASE WHEN a.StatusCheck_CODE NOT IN (''' + @Lc_StatusCheckOutstanding_CODE + ''',''' + @Lc_StatusCheckEftTransfer_CODE + ''','''+ @Lc_StatusCheckCashed_CODE+''',''' + @Lc_StatusCheckRejectedEft_CODE + ''') THEN
                    a.StatusCheck_CODE
              ELSE NULL
          END)  VoidAction_CODE,
          a.ReasonStatus_CODE ,          
          b.Worker_ID Worker_ID,
          a.MediumDisburse_CODE MediumDisburse_CODE,
          a.EventGlobalBeginSeq_NUMB ,
          COUNT(1) OVER()  RowCount_NUMB,
          ( CASE WHEN a.MediumDisburse_CODE =''' + @Lc_MediumDisburseCheck_CODE + ''' AND a.StatusCheck_CODE IN(''' + @Lc_StatusCheckOutstanding_CODE + ''') THEN
             ''' + @Lc_Yes_TEXT + '''
            ELSE
            ''' + @Lc_No_TEXT + '''
           END
          ) UpdateFlag_INDC,
          a.StatusCheck_CODE StatusCheckOld_CODE         ' + '  ,ROW_NUMBER() OVER ( ORDER BY Disburse_DATE DESC) rnum  FROM DSBH_Y1 a, GLEV_Y1 b
          WHERE a.EndValidity_DATE =''' + CAST(@Ld_High_DATE AS CHAR(10)) + '''
          AND  b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB';
  SET @Ls_SqlTemp_TEXT = @Ls_SqlSelect_TEXT + @Ls_SqlWhere_TEXT + ' ) AS Z where rnum<=' + CONVERT(VARCHAR, @Ai_RowTo_NUMB) + ') AS A WHERE rnum1 >=' + CONVERT(VARCHAR, @Ai_RowFrom_NUMB);

  EXEC(@Ls_SqlTemp_TEXT);
 END -- END OF DSBH_RETRIEVE_S7;


GO
