/****** Object:  StoredProcedure [dbo].[LSTT_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LSTT_RETRIEVE_S12] 
( 
	@An_MemberMci_IDNO		NUMERIC(10,0),
	@Ad_End_DATE			DATE,
	@Ad_StatusLocate_DATE	DATE OUTPUT
)  
AS
/*
 *     PROCEDURE NAME    : LSTT_RETRIEVE_S12
 *     DESCRIPTION       : This procedure is used to retrieve the Locate Date
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 03-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN
		SET @Ad_StatusLocate_DATE				= NULL;
    DECLARE @Ld_Low_DATE				DATE    = '01/01/0001',
			@Lc_StatusLocateL_CODE		CHAR(1) = 'L';
    
     SELECT @Ad_StatusLocate_DATE = ISNULL(MAX (l.StatusLocate_DATE), @Ld_Low_DATE) 
       FROM LSTT_Y1 l
      WHERE l.MemberMci_IDNO = @An_MemberMci_IDNO
        AND l.StatusLocate_CODE = @Lc_StatusLocateL_CODE
        AND l.StatusLocate_DATE <= @Ad_End_DATE;
	                      
END;  --END OF LSTT_RETRIEVE_S12


GO
