/****** Object:  StoredProcedure [dbo].[PARM_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[PARM_RETRIEVE_S15]
 (
  @Ac_Job_ID   CHAR(7),
  @Ad_Run_DATE DATE     OUTPUT
  )
AS  
/*  
 *     PROCEDURE NAME    : PARM_RETRIEVE_S15
 *     DESCRIPTION       : Retrieve the Run_DATE of the BIFM and BIPA batches from the PARM_Y1 table. 
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 05-MAY-2012   
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN 
     DECLARE @Ld_High_DATE DATE = '12/31/9999';
         SET @Ad_Run_DATE = NULL;
      SELECT @Ad_Run_DATE = a.Run_DATE
        FROM PARM_Y1 a
       WHERE a.Job_ID = @Ac_Job_ID 
         AND a.EndValidity_DATE = @Ld_High_DATE;
		  
END;--End of PARM_RETRIEVE_S15  


GO
