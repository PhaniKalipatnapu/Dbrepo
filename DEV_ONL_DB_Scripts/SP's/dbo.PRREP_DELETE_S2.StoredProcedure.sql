/****** Object:  StoredProcedure [dbo].[PRREP_DELETE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRREP_DELETE_S2] (

			@Ac_Session_ID		 CHAR(30)              
			)
AS

/*
 *     PROCEDURE NAME    : PRREP_DELETE_S2
 *     DESCRIPTION       : This procedure deletes records from PRREP_Y1 table after backout and repost process for the session.
 *
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
      
      DELETE PRREP_Y1
       WHERE Session_ID = @Ac_Session_ID;
       
      
      DECLARE @Ln_RowsAffected_NUMB	NUMERIC(10);
         
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
      
       SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;


END; --END OF PRREP_DELETE_S2


GO
