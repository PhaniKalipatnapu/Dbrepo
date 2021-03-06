/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S15] (
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_TransactionFrom_DATE   DATE,
 @Ad_TransactionTo_DATE     DATE,
 @Ac_FullDisplay_NAME       CHAR(37),
 @Ai_RowFrom_NUMB           INT=1,
 @Ai_RowTo_NUMB             INT=10
 )
AS
 /*  
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S15  
  *     DESCRIPTION       : Retrieve Csenet Transaction Header Block details for a Transaction Date, Last Name, First Name, Other State Fips, Function Code, Action Code, Reason Code, and Transaction Header Idno that common between three tables.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_ActionRequestRequest_CODE		CHAR(1) = 'R', 
          @Lc_ActionRequestProvide_CODE     CHAR(1) = 'P',         
          @Lc_FunctionQuickLocate_CODE		CHAR(3) = 'LO1',
          @Lc_Space_TEXT					CHAR(1) = ' ';

  SELECT Y.IVDOutOfStateFips_CODE,
         Y.Transaction_DATE,
         (SELECT S.State_NAME
            FROM STAT_Y1 S
           WHERE S.StateFips_CODE = Y.IVDOutOfStateFips_CODE) AS State_NAME,
         Y.Case_IDNO,
         Y.IVDOutOfStateCase_ID,
         Y.DescriptionFar_TEXT,
         Y.TranStatus_CODE,
         Y.ExchangeMode_CODE,
         Y.TransHeader_IDNO,
         Y.Function_CODE,
         Y.Action_CODE,
         Y.Reason_CODE,
         Y.RowCount_NUMB
    FROM (SELECT X.Transaction_DATE,
                 X.IVDOutOfStateFips_CODE,
                 X.Case_IDNO,
                 X.IVDOutOfStateCase_ID,
                 X.DescriptionFar_TEXT,
                 X.TranStatus_CODE,
                 X.ExchangeMode_CODE,
                 X.TransHeader_IDNO,
                 X.Function_CODE,
                 X.Action_CODE,
                 X.Reason_CODE,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM AS row_num
            FROM (SELECT Z.Transaction_DATE,
                         Z.IVDOutOfStateFips_CODE,
                         Z.Case_IDNO,
                         Z.IVDOutOfStateCase_ID,
                         Z.DescriptionFar_TEXT,
                         Z.TranStatus_CODE,
                         Z.ExchangeMode_CODE,
                         Z.TransHeader_IDNO,
                         Z.Function_CODE,
                         Z.Action_CODE,
                         Z.Reason_CODE,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER(ORDER BY Z.Transaction_DATE DESC) AS ORD_ROWNUM
                    FROM (SELECT a.Transaction_DATE,
                                 a.IVDOutOfStateFips_CODE,
                                 a.Case_IDNO,
                                 a.IVDOutOfStateCase_ID,
                                 b.DescriptionFar_TEXT,
                                 a.TranStatus_CODE,
                                 a.ExchangeMode_CODE,
                                 a.TransHeader_IDNO,
                                 a.Function_CODE,
                                 a.Action_CODE,
                                 a.Reason_CODE
                            FROM CTHB_Y1 a
                                 JOIN CFAR_Y1 b
                                  ON a.Action_CODE = b.Action_CODE
                                     AND a.Function_CODE = b.Function_CODE
                                     AND a.Reason_CODE = b.Reason_CODE
                                 JOIN CNCB_Y1 c
                                  ON c.TransHeader_IDNO = a.TransHeader_IDNO
                           WHERE (@Ad_TransactionFrom_DATE IS NULL
                                   OR (@Ad_TransactionFrom_DATE IS NOT NULL
                                       AND a.Transaction_DATE >= @Ad_TransactionFrom_DATE))
                             AND (@Ad_TransactionTo_DATE IS NULL
                                   OR (@Ad_TransactionTo_DATE IS NOT NULL
                                       AND a.Transaction_DATE <= @Ad_TransactionTo_DATE))
                             AND (@Ac_FullDisplay_NAME IS NULL
                                   OR (@Ac_FullDisplay_NAME IS NOT NULL
                                       AND ((RTRIM(c.First_NAME) + @Lc_Space_TEXT + RTRIM(c.Last_NAME) = @Ac_FullDisplay_NAME)
                                             OR (RTRIM(c.Last_NAME) + @Lc_Space_TEXT + RTRIM(c.First_NAME) = @Ac_FullDisplay_NAME)
                                             OR ((RTRIM(c.First_NAME) = @Ac_FullDisplay_NAME)
                                                  OR (RTRIM(c.Last_NAME) = @Ac_FullDisplay_NAME)))))
                             AND (@Ac_IVDOutOfStateFips_CODE IS NULL
                                   OR (@Ac_IVDOutOfStateFips_CODE IS NOT NULL
                                       AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE))
                             AND a.Function_CODE = @Lc_FunctionQuickLocate_CODE
                             AND a.Action_CODE in ( @Lc_ActionRequestRequest_CODE , @Lc_ActionRequestProvide_CODE ) ) AS Z) AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.row_num >= @Ai_RowFrom_NUMB;
 END; --End of CTHB_RETRIEVE_S15  

GO
