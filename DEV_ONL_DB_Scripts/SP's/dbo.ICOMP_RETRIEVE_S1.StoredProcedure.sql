/****** Object:  StoredProcedure [dbo].[ICOMP_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ICOMP_RETRIEVE_S1] (
			 @An_Seq_IDNO	 NUMERIC(19,0)	 OUTPUT
			)
AS
/*
 *     PROCEDURE NAME    : ICOMP_RETRIEVE_S1
 *     DESCRIPTION       : This procedure returns next sequence number for seq_comp from ICOMP_Y1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 07-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */ 
BEGIN 
	DECLARE @Ln_Seq_IDNO		NUMERIC(19, 0),
			@Ld_Current_DATE	DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		
		SET @An_Seq_IDNO = NULL;
     
         BEGIN TRANSACTION
         
             DELETE  FROM ICOMP_Y1;             
             
             INSERT INTO ICOMP_Y1 
			 VALUES ( @Ld_Current_DATE  
					);
										
             SELECT @Ln_Seq_IDNO =Seq_IDNO 
			   FROM ICOMP_Y1;
			   
         COMMIT TRANSACTION

      SELECT @An_Seq_IDNO = @Ln_Seq_IDNO;
                  
END; -- END OF  ICOMP_RETRIEVE_S1

GO
