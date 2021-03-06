/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S11]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S11] (
 @Ac_TypeOthp_CODE   CHAR(1),
 @As_OtherParty_NAME VARCHAR(60),
 @An_County_IDNO     NUMERIC(3),
 @Ai_RowFrom_NUMB    INT,
 @Ai_RowTo_NUMB      INT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S11
  *     DESCRIPTION       : Retrieves the records of the location details for the given name, county, type of the other party for the valid record.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT	CHAR(1) = '%',
          @Ld_High_DATE			DATE	= '12/31/9999';

  SELECT X.OtherParty_IDNO,
         X.OtherParty_NAME,
         X.City_ADDR,
         X.State_ADDR,
         X.Phone_NUMB,
         RowCount_NUMB
    FROM (SELECT Y.OtherParty_IDNO,
                 Y.OtherParty_NAME,
                 Y.City_ADDR,
                 Y.State_ADDR,
                 Y.Phone_NUMB,
                 Y.RowCount_NUMB,
                 Y.REC_NUMB
            FROM (SELECT O.OtherParty_IDNO,
                         O.OtherParty_NAME,
                         O.City_ADDR,
                         O.State_ADDR,
                         O.Phone_NUMB,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER (ORDER BY O.OtherParty_NAME) AS REC_NUMB
                    FROM OTHP_Y1 O
                   WHERE O.TypeOthp_CODE = @Ac_TypeOthp_CODE
                     AND O.County_IDNO = ISNULL (@An_County_IDNO, O.County_IDNO)
                     AND (O.OtherParty_NAME LIKE (@Lc_Percentage_PCT + ISNULL(@As_OtherParty_NAME, O.OtherParty_NAME) + @Lc_Percentage_PCT))
                     AND O.EndValidity_DATE = @Ld_High_DATE)AS Y
           WHERE Y.REC_NUMB <= @Ai_RowTo_NUMB)AS X
   WHERE X.REC_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY X.REC_NUMB;
 END; -- END OF OTHP_RETRIEVE_S11



GO
