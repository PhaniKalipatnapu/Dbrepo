/****** Object:  StoredProcedure [dbo].[POBLE_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POBLE_DELETE_S1]  
(
     @Ac_SignedOnWorker_ID		 CHAR(30)              
)
AS

/*
 *     PROCEDURE NAME    : POBLE_DELETE_S1
 *     DESCRIPTION       : Procedure to delete records in temporary table POBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 16-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

 BEGIN
      DELETE POBLE_Y1
       WHERE Worker_ID = @Ac_SignedOnWorker_ID;
      
     DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
     
         SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
     
      SELECT @Ln_RowsAffected_NUMB;
 
 END;--End of POBLE_DELETE_S1 


GO
