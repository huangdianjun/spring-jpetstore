<%@ include file="../common/IncludeTop.jsp"%>

<div id="BackLink">
    <a href="${pageContext.request.contextPath}/catalog">Return to
        Main Menu</a>
</div>

<div id="Catalog">

    <table>
        <tr>
            <th>&nbsp;</th>
            <th>Product ID</th>
            <th>Name</th>
        </tr>
        <c:forEach var="product" items="${productList}">
            <tr>
                <td><a
                    href="${pageContext.request.contextPath}/catalog/viewProduct?productId=${fn:escapeXml(product.productId)}">${product.description}<%--  XSS Vulnerable! --%></a></td>
                <td><b> <a
                        href="${pageContext.request.contextPath}/catalog/viewProduct?productId=${fn:escapeXml(product.productId)}"><font
                            color="BLACK">
                                ${fn:escapeXml(product.productId)} </font></a>
                </b></td>
                <td>${fn:escapeXml(product.name)}</td>
            </tr>
        </c:forEach>
    </table>

</div>

<%@ include file="../common/IncludeBottom.jsp"%>




