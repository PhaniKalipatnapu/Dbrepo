/****** Object:  StoredProcedure [dbo].[BCHK_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BCHK_INSERT_S1]  
	(
     @An_MemberMci_IDNO		 	NUMERIC(10,0),
     @An_EventGlobalSeq_NUMB	NUMERIC(19,0), 
     @Ac_BadCheck_INDC		 	CHAR(1)		 ,
     @An_CountBadCheck_QNTY		NUMERIC(3,0)      
    )
AS

/*
 *     PROCEDURE NAME    : BCHK_INSERT_S1
 *     DESCRIPTION       : Inserts data into BadCheckDetails_T1
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 28-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
     INSERT BCHK_Y1
            (MemberMci_IDNO, 
             EventGlobalSeq_NUMB,
             BadCheck_INDC,
             CountBadCheck_QNTY             
            )
     VALUES (@An_MemberMci_IDNO, 	  --MemberMci_IDNO
     		 @An_EventGlobalSeq_NUMB, --EventGlobalSeq_NUMB
     		 @Ac_BadCheck_INDC,  	  --BadCheck_INDC
             @An_CountBadCheck_QNTY   --CountBadCheck_QNTY             
            );
                  
END; --End of BCHK_INSERT_S1


GO
