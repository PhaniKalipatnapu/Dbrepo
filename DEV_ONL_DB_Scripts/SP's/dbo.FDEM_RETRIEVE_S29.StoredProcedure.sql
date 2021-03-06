/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FDEM_RETRIEVE_S29]
		(                
		         
		   @An_Case_IDNO		NUMERIC(6,0)		, 
		   @Ac_File_ID			CHAR(10)
		)                
AS                
      
/*      
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S29     
 *     DESCRIPTION       : Retrirve Petition ID, Document Type and Document Name details for a case & file id      
 *     DEVELOPED BY      : IMP Team       
 *     DEVELOPED ON      : 19-oct-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
*/      
  BEGIN
  
  DECLARE
	  @Lc_TypeDocP_CODE		CHAR(1) ='P',
	  @Lc_TableFmis_ID		CHAR(4) ='FMIS',
	  @Lc_TableSubDsrc_ID	CHAR(4) ='DSRC',
	  @Ld_High_DATE			DATE	='12/31/9999';
  
  SELECT  s.Petition_IDNO,
		  s.TypeDoc_CODE,
		  s.DocReference_CODE,
		  s.SourceDoc_CODE
	FROM  FDEM_Y1 s
	JOIN 
		REFM_Y1 r
			ON
				s.SourceDoc_CODE=r.Value_CODE	
WHERE 
	s.Case_IDNO=@An_Case_IDNO 
AND s.FILE_ID=@Ac_File_ID 
AND s.TypeDoc_CODE=@Lc_TypeDocP_CODE 
AND r.Table_ID=@Lc_TableFmis_ID 
AND r.TableSub_ID=@Lc_TableSubDsrc_ID 
AND s.EndValidity_DATE=@Ld_High_DATE;
                                         
 END;	--END OF FDEM_RETRIEVE_S29
 

GO
