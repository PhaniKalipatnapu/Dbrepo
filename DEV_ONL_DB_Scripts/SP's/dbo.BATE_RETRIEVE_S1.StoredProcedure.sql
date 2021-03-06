/****** Object:  StoredProcedure [dbo].[BATE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[BATE_RETRIEVE_S1]
		(  
     		@Ac_Job_ID		        CHAR(7)     ,
     		@As_Process_NAME		VARCHAR(100),
     		@Ad_EffectiveRun_DATE	DATE        ,
     		@Ac_TypeError_CODE		CHAR(1)     ,
     		@Ai_RowFrom_NUMB        INT =  1    ,
     		@Ai_RowTo_NUMB          INT = 10  
        )             
AS

/*
*     PROCEDURE NAME     : BATE_RETRIEVE_S1
 *     DESCRIPTION       : Retrieve Batch Process Date, Job Idno, Package name, Error Type, Date and Time the record was created, Error Description, and Key Values Text for a Batch Process Date, Job Idno, Package Name, Error Type, and Row Count.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

BEGIN

      DECLARE 
         @Ld_High_DATE	DATE = '12/31/9999',
         @Li_Zero_NUMB  SMALLINT = 0;;
        
      SELECT BSO.Job_ID,
		BSO.Process_NAME ,
		BSO.EffectiveRun_DATE,
		BSO.Create_DTTM , 
		BSO.TypeError_CODE ,  
		BSO.ListKey_TEXT , 
        BSO.DescriptionErrorBatch_TEXT,
        BSO.Error_CODE,
        BSO.DescriptionError_TEXT,
        (
			SELECT JP.DescriptionJob_TEXT
			 FROM PARM_Y1  JP
			WHERE 
				JP.Job_ID         = BSO.Job_ID
			AND JP.EndValidity_DATE = @Ld_High_DATE
		) DescriptionJob_TEXT, 
		BSO.RowCount_NUMB
       FROM ( 
       		 SELECT X.EffectiveRun_DATE, 
               		X.Job_ID, 
               		X.Process_NAME, 
               		X.TypeError_CODE, 
               		X.Create_DTTM, 
               		X.ListKey_TEXT, 
               		X.Error_CODE,
               		X.DescriptionErrorBatch_TEXT,
               		X.DescriptionError_TEXT, 
               		X.RowCount_NUMB, 
               		X.ORD_ROWNUM AS ORD_ROWNUM
                 FROM (
                 			SELECT BS.EffectiveRun_DATE, 
                     			BS.Job_ID, 
                     			BS.Process_NAME, 
                     			BS.TypeError_CODE, 
                     			BS.Create_DTTM, 
                     			BS.ListKey_TEXT, 
                     			BS.Error_CODE,
                     			BS.DescriptionError_TEXT AS DescriptionErrorBatch_TEXT,
                     			b.DescriptionError_TEXT,
                     			COUNT(1) OVER() AS RowCount_NUMB, 
                     			ROW_NUMBER() OVER(
                     			   					ORDER BY BS.EffectiveRun_DATE DESC
                     			   				  ) AS ORD_ROWNUM
                   			 FROM BATE_Y1  BS
                   	        LEFT OUTER JOIN 
                   	        	EMSG_Y1 b
                            		ON
                                    	b.Error_CODE = BS.Error_CODE
                            WHERE 
                               BS.EffectiveRun_DATE = @Ad_EffectiveRun_DATE
                            AND BS.Job_ID          = ISNULL(@Ac_Job_ID, BS.Job_ID) 
                            AND BS.Process_NAME      = ISNULL(@As_Process_NAME, BS.Process_NAME) 
                            AND (
                               		@Ac_TypeError_CODE IS NULL 
                                  OR @Ac_TypeError_CODE IS NOT NULL 
                                  AND BS.TypeError_CODE = @Ac_TypeError_CODE
                               )
                        )  AS X
                WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB) 
                OR  (@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
            )  AS BSO
      WHERE BSO.ORD_ROWNUM >= @Ai_RowFrom_NUMB 
      OR (@Ai_RowFrom_NUMB = @Li_Zero_NUMB);

                  
END; --End of BATE_RETRIEVE_S1


GO
