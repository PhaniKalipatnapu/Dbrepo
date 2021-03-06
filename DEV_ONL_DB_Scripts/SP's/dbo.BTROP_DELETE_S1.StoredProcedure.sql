/****** Object:  StoredProcedure [dbo].[BTROP_DELETE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[BTROP_DELETE_S1] (
     @An_Report_IDNO    NUMERIC(10,0)
     )             
AS  
/*  
 *     PROCEDURE NAME    : BTROP_DELETE_S1  
 *     DESCRIPTION       : Used to delete an existing report profile
						   This procedure is used to delete an existing report profile.
						   Only the worker who created a particular report profile can delete
						   it while others will not be authorized to delete.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
 
	DELETE BTROP_Y1
     WHERE Report_IDNO=@An_Report_IDNO;
     
    DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
    DECLARE @Ls_ErrorMessage_TEXT VARCHAR(MAX);
    
        SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
        SET @Ls_ErrorMessage_TEXT =''; 
        
     SELECT @Ln_RowsAffected_NUMB;  
 
 END; --End of BTROP_DELETE_S1

GO
