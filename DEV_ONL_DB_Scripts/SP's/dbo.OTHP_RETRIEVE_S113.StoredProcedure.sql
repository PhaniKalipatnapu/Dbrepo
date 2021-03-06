/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S113]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S113] (
 @Ac_TypeOthp_CODE   CHAR(1),
 @As_OtherParty_NAME VARCHAR(60),
 @An_County_IDNO     NUMERIC(3, 0),
 @Ai_RowFrom_NUMB    INT,
 @Ai_RowTo_NUMB      INT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S113
  *     DESCRIPTION       : fetch the records of the location details for the given name, county, type of the other party where enddate validity is highdate and other party type exists in cross reference reason code for the corresponding code type value and the process for which this type and reason is cross referenced. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-MAR-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT CHAR(1) = '%',
          @Ld_High_DATE      DATE = '12/31/9999',
          @Lc_Empty_TEXT    CHAR(1) ='';;

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
            FROM (SELECT O2.OtherParty_IDNO,
                         O2.OtherParty_NAME,
                         O2.City_ADDR,
                         O2.State_ADDR,
                         O2.Phone_NUMB,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER (ORDER BY O2.OtherParty_NAME) AS REC_NUMB
                    	 FROM OFIC_Y1 O1
                     	 JOIN OTHP_Y1 O2
						 ON O1.OtherParty_IDNO = O2.OtherParty_IDNO
                   WHERE 
                   	O2.TypeOthp_CODE = @Ac_TypeOthp_CODE
                     AND O2.County_IDNO = ISNULL (@An_County_IDNO, O2.County_IDNO)
                     AND (O2.OtherParty_NAME LIKE (@Lc_Percentage_PCT + ISNULL(@As_OtherParty_NAME, @Lc_Empty_TEXT) + @Lc_Percentage_PCT))
                     AND O2.EndValidity_DATE = @Ld_High_DATE
                     AND O1.EndValidity_DATE = @Ld_High_DATE)AS Y
           WHERE Y.REC_NUMB <= @Ai_RowTo_NUMB)AS X
   WHERE X.REC_NUMB >= @Ai_RowFrom_NUMB
   ORDER BY X.REC_NUMB;
   
 END; -- END OF OTHP_RETRIEVE_S113



GO
