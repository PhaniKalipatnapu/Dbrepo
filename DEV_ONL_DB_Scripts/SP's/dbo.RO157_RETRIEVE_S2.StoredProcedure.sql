/****** Object:  StoredProcedure [dbo].[RO157_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_RETRIEVE_S2](
			@Ad_BeginFiscal_DATE	DATE,
			@Ad_EndFiscal_DATE		DATE,
			@Ac_TypeReport_CODE		CHAR(1),
			@Ai_Count_QNTY			INT   OUTPUT
	)			
AS  
  /*  
 *     PROCEDURE NAME    : RO157_RETRIEVE_S2   
 *     DESCRIPTION       : Checking Details are exists or Not
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
	BEGIN  
		   SET @Ai_Count_QNTY  = NULL;
	   DECLARE @Lc_LineNo8_TEXT		CHAR(1) = '8',
			   @Lc_LineNo9_TEXT		CHAR(1)	= '9',
			   @Lc_LineNo8A_TEXT	CHAR(2)	= '8A',
			   @Lc_LineNo10_TEXT	CHAR(2)	= '10';
				
		SELECT @Ai_Count_QNTY = COUNT (1)
		  FROM RO157_Y1 R
		 WHERE R.BeginFiscal_DATE = @Ad_BeginFiscal_DATE
           AND R.EndFiscal_DATE = @Ad_EndFiscal_DATE
           AND R.TypeReport_CODE = @Ac_TypeReport_CODE
           AND R.LineNo_TEXT  NOT IN(@Lc_LineNo8_TEXT,@Lc_LineNo8A_TEXT, @Lc_LineNo9_TEXT,@Lc_LineNo10_TEXT);
         
     END;	--- End of RO157_RETRIEVE_S2

GO
