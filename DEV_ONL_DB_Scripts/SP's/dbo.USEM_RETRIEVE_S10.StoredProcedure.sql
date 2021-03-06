/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S10] (
 @An_Office_IDNO  NUMERIC(3, 0),
 @Ac_Last_NAME    CHAR(20),
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S10
  *     DESCRIPTION       : Retrieve the Worker Details for given office number
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  SELECT Y.Worker_ID,
                 Y.Last_NAME,
                 Y.Suffix_NAME,
                 Y.First_NAME,
                 Y.Middle_NAME,
                 Y.RowCount_NUMB,
                 Y.Row_NUMB
            FROM (SELECT X.Worker_ID,
                         X.Last_NAME,
                         X.Suffix_NAME,
                         X.First_NAME,
                         X.Middle_NAME,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY X.Last_NAME, X.Suffix_NAME, X.First_NAME, X.Middle_NAME) AS Row_NUMB
                    FROM (SELECT DISTINCT
                                 b.Worker_ID,
                                 b.Last_NAME,
                                 b.Suffix_NAME,
                                 b.First_NAME,
                                 b.Middle_NAME
                            FROM USRL_Y1 a
                                 JOIN USEM_Y1 b
                                  ON a.Worker_ID = b.Worker_ID
                           WHERE a.Office_IDNO = @An_Office_IDNO
                               AND b.Last_NAME >= ISNULL(@Ac_Last_NAME, b.Last_NAME)
                               AND @Ld_Systemdate_DTTM BETWEEN b.BeginEmployment_DATE AND b.EndEmployment_DATE
                               AND a.EndValidity_DATE = @Ld_High_DATE
                               AND b.EndValidity_DATE = @Ld_High_DATE
                             ) AS X) AS Y
          WHERE Y.Row_NUMB BETWEEN  @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB
        ORDER BY Row_NUMB;
 END; -- END OF USEM_RETRIEVE_S10


GO
