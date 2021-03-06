/****** Object:  StoredProcedure [dbo].[NOST_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NOST_RETRIEVE_S5](  
 @Ac_Worker_ID         CHAR(30),  
 @As_Pin_TEXT          VARCHAR(64),
 @Ai_Days_Expire_NUMB  INT OUTPUT 
 ) 
 AS  
  
/*  
 *     PROCEDURE NAME    : NOST_RETRIEVE_S5 
 *     DESCRIPTION       : This procedure used to get Number of days Completed after Notary pin changed
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 18-SEP-2012  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/

BEGIN  
	DECLARE @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
	SELECT  @Ai_Days_Expire_NUMB = DATEDIFF(DD,d.BeginValidity_DATE,@Ld_Current_DTTM) 
	FROM
	(SELECT MIN(X.BeginValidity_DATE) AS BeginValidity_DATE 
	FROM
	(SELECT MIN(BeginValidity_DATE) AS BeginValidity_DATE 
			FROM 
			HNOST_Y1 
			WHERE 
			Worker_ID=@Ac_Worker_ID
			AND Pin_TEXT=@As_Pin_TEXT
			AND BeginValidity_DATE = Update_DTTM
			UNION
			SELECT 
			MIN(BeginValidity_DATE) AS BeginValidity_DATE 
			FROM NOST_Y1 WHERE 
			Worker_ID=@Ac_Worker_ID
			AND Pin_TEXT=@As_Pin_TEXT
			AND BeginValidity_DATE = Update_DTTM
			)X
		)d
		
END;--End of NOST_RETRIEVE_S5

GO
