/****** Object:  StoredProcedure [dbo].[SHOL_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SHOL_RETRIEVE_S12] (
  @Ad_Start_DATE      DATE
 
 )
AS
 /*                                                                                                                                                            
  *     PROCEDURE NAME    : SHOL_RETRIEVE_S12                                                                                                                   
  *     DESCRIPTION       : Retrieve Holiday Date for a column value where column value is retrieved from Gtemp_Spro_T1 table.                                                                                                                                                                                                                                                                  
  *     DEVELOPED BY      : IMP Team                                                                                                                        
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                        
  *     MODIFIED BY       :                                                                                                                                    
  *     MODIFIED ON       :                                                                                                                                    
  *     VERSION NO        : 1                                                                                                                                  
 */
 BEGIN
  DECLARE @Lc_Available_CODE   CHAR(1) = 'A',
          @Lc_Holiday_CODE     CHAR(1) = 'H',
          @Lc_Screen_INDC      CHAR(1) = 'M', 
          @Li_MinusOne_NUMB    SMALLINT = -1,
          @Ld_Start_DATE DATE = CONVERT(VARCHAR, MONTH(@Ad_Start_DATE)) + '/01/' + CONVERT(VARCHAR, YEAR(@Ad_Start_DATE));
          
  DECLARE @Ld_End_DATE DATE = DATEADD(d, -1, DATEADD(m, 1, @Ld_Start_DATE));


  SELECT X.Available_DATE AS Schedule_DATE,
         CASE
          WHEN X.Available_DATE = (SELECT s.Holiday_DATE
                                   FROM SHOL_Y1 s
                                  WHERE s.Holiday_DATE = X.Available_DATE
                                    AND s.OthpLocation_IDNO = @Li_MinusOne_NUMB)
           THEN @Lc_Holiday_CODE
          ELSE @Lc_Available_CODE
         END AS Availability_INDC
    FROM (SELECT Available_DATE
           FROM dbo.BATCH_COMMON$SF_GET_AVAILABLE_SCHEDULE_DATE(@Li_MinusOne_NUMB,@Ld_Start_DATE,@Ld_End_DATE,@Lc_Screen_INDC)) AS X
   ORDER BY Schedule_DATE;
 END; --END OF SHOL_RETRIEVE_S12                                                                                                                                                           




GO
