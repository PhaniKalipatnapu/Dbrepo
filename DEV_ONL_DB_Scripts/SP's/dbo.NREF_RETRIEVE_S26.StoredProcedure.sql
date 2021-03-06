/****** Object:  StoredProcedure [dbo].[NREF_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREF_RETRIEVE_S26] (
 @As_Search_TEXT  VARCHAR(100),
 @Ai_RowFrom_NUMB INT = 1,
 @Ai_RowTo_NUMB   INT = 10
 )
AS
 /*                                                                                                                                                       
  *     PROCEDURE NAME    : NREF_RETRIEVE_S26                                                                                                              
  *     DESCRIPTION       : Retrieve Notice Idno and Description of the Notice for a Notice Description Search Text and Batch Online code is equal to 'S'.
  *     DEVELOPED BY      : IMP Team                                                                                                                      
  *     DEVELOPED ON      : 05-SEP-2011                                                                                                                     
  *     MODIFIED BY       :                                                                                                                               
  *     MODIFIED ON       :                                                                                                                               
  *     VERSION NO        : 1                                                                                                                             
 */
 BEGIN
  DECLARE @Lc_Percentage_PCT       CHAR(1) = '%',
          @Ld_High_DATE            DATE = '12/31/9999',
          @Lc_BatchOnlineSpro_CODE CHAR(1) = 'S',
          @Li_One_NUMB				SMALLINT = 1,
          @Lc_Empty_TEXT			CHAR(1) = '',
          @Lc_Noticecsi03_ID       CHAR(8) = 'CSI-03',
          @Lc_Noticecsi04_ID       CHAR(8) = 'CSI-04';			   

  SELECT C.Notice_ID,
         C.DescriptionNotice_TEXT,
         C.Count_QNTY AS RowCount_NUMB
    FROM (SELECT A.Notice_ID,
                 A.DescriptionNotice_TEXT,
                 A.Row_Num,
                 A.Count_QNTY,
                 A.ORD_ROWNUM
            FROM (SELECT B.Notice_ID,
                         B.DescriptionNotice_TEXT,
                         B.Row_Num,
                         COUNT(1) OVER() AS Count_QNTY,
                         ROW_NUMBER() OVER( ORDER BY B.DescriptionNotice_TEXT) AS ORD_ROWNUM
                    FROM (SELECT A.Notice_ID,
                                 A.DescriptionNotice_TEXT,
                                 ROW_NUMBER() OVER(PARTITION BY A.Notice_ID ORDER BY A.DescriptionNotice_TEXT) AS Row_Num
                            FROM NREF_Y1 A
                           WHERE A.Notice_ID IN (@Lc_Noticecsi03_ID, @Lc_Noticecsi04_ID)
                             AND A.DescriptionNotice_TEXT LIKE ISNULL(@As_Search_TEXT,RTRIM(@Lc_Empty_TEXT)) + @Lc_Percentage_PCT
                             AND A.EndValidity_DATE = @Ld_High_DATE) AS B
                   WHERE B.Row_Num = @Li_One_NUMB) AS A
           WHERE A.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS C
   WHERE C.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY ORD_ROWNUM;
 END; --END OF NREF_RETRIEVE_S26                                                                                                                                                  ;



GO
