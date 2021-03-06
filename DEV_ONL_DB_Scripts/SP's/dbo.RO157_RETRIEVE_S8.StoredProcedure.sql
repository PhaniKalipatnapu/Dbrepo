/****** Object:  StoredProcedure [dbo].[RO157_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_RETRIEVE_S8]
 (
  @Ad_BeginFiscal_DATE	DATE,
  @Ad_EndFiscal_DATE	DATE,
  @Ai_Count_QNTY		INT	 OUTPUT
  )
 AS
  /*                                                                                                                                                                               
  *     PROCEDURE NAME    : RO157_RETRIEVE_S8                                                                                                                                       
  *     DESCRIPTION       : GETS THE RECORD COUNT VALUE FOR THE GIVEN FISCAL DATE.
  *     DEVELOPED BY      : IMP TEAM                                                                                                                                            
  *     DEVELOPED ON      : 27-NOV-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
BEGIN
	DECLARE
			@Lc_LineNo30_TEXT CHAR(2) = '30',
			@Lc_LineNo31_TEXT CHAR(2) = '31',
			@Lc_LineNo32_TEXT CHAR(2) = '32';
	   SET  @Ai_Count_QNTY = NULL;        
	
	SELECT @Ai_Count_QNTY = COUNT (1) 
	  FROM RO157_Y1 R
	 WHERE R.LineNo_TEXT IN(@Lc_LineNo30_TEXT,@Lc_LineNo31_TEXT,@Lc_LineNo32_TEXT)
	   AND R.BeginFiscal_DATE =	@Ad_BeginFiscal_DATE
	   AND R.EndFiscal_DATE	  =	@Ad_EndFiscal_DATE;
END;--End of RO157_RETRIEVE_S8

GO
