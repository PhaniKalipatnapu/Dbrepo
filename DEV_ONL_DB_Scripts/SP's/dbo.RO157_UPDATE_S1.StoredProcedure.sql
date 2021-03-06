/****** Object:  StoredProcedure [dbo].[RO157_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RO157_UPDATE_S1](	
	@Ad_BeginFiscal_DATE		DATE,
	@Ad_EndFiscal_DATE			DATE,
	@Ac_SignedOnWorker_ID		CHAR(30),
	@Ac_LineNo_TEXT				CHAR(3),
	@An_Tot_QNTY				NUMERIC(11,2)
	)
 AS
  /*                                                                                                                                                                               
  *     PROCEDURE NAME    : RO157_UPDATE_S1                                                                                                                                       
  *     DESCRIPTION       : UPDATING THE DETAILS FOR THE GIVEN LINE NO
  *     DEVELOPED BY      : IMP TEAM                                                                                                                                            
  *     DEVELOPED ON      : 02-SEP-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
  BEGIN
	UPDATE RO157_Y1 
	   SET Tot_QNTY	=	@An_Tot_QNTY ,
           Worker_ID	=	@Ac_SignedOnWorker_ID
	 WHERE BeginFiscal_DATE	=	@Ad_BeginFiscal_DATE
	   AND EndFiscal_DATE	=	@Ad_EndFiscal_DATE
	   AND LineNo_TEXT		=	@Ac_LineNo_TEXT;
		
  DECLARE 
		  @Ln_RowsAffected_NUMB NUMERIC(10);
     SET  @Ln_RowsAffected_NUMB = @@ROWCOUNT;
  SELECT  @Ln_RowsAffected_NUMB;      
 	
 END; -- End of RO157_UPDATE_S1  

GO
